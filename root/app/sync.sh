#!/usr/bin/with-contenv sh

echo "INFO: Starting sync.sh PID $$ $(date)"

if [ -z "$BUCKET" ]; then
  echo "ERROR: Missing BUCKET environment variable."
  exit 1
fi

# sync the log bucket
echo "INFO: Syncing from bucket s3://${BUCKET}"
aws s3 sync s3://${BUCKET} /logs

echo "INFO: Combining log files..."
rm -f /logs/combined.log.gz
cat /logs/*.gz > /logs/combined.log.gz
gzip -f -d /logs/combined.log.gz

sed -i.orig '/^#/d' /logs/combined.log  # remove comments
rm -f /logs/combined.log.orig

echo "INFO: Generating analytics html from combined log file."
eval goaccess --log-format CLOUDFRONT -o /config/html/${HTML_FILENAME:-index}.html ${GOACCESS_ARGS} /logs/combined.log

case "$POST_ACTION" in
  "" )
    ;;

  * )
    if [ -x "${POST_ACTION}" ]; then
      echo "INFO: Executing post action script: ${POST_ACTION}"
      sh -c "${POST_ACTION}" "/config/html/${HTML_FILENAME:-index}.html"
    elif [ -x "/config/${POST_ACTOIN}" ]; then
      echo "INFO: Executing post action script: ${POST_ACTION}"
      sh -c "/config/${POST_ACTION}" "/config/html/${HTML_FILENAME:-index}.html"
    else
      echo "INFO: Executing post action: ${POST_ACTION}"
      eval "${POST_ACTION}"
    fi
    ;;

esac

if [ -n "$PRUNE" ];then
  delete_cmd="Objects=["
  log_count=0
  for f in $(find /logs/ -mtime +"${PRUNE}" ! -name 'combined.log.gz' -name '*.gz' -type f);do
    if [ ${log_count} -ne 0 ];then
      delete_cmd="${delete_cmd},"
    fi
    
    delete_cmd="${delete_cmd}{Key=${f#/logs/}}"

    let log_count++
  done
  delete_cmd="${delete_cmd}],Quiet=false"
  
  if [ $log_count -gt 0 ];then
    echo "INFO: Pruning ${log_count} old logs."

    # aws s3api desperately wants to open the results in less, which is shitty for scripting,
    # so we'll just write it to a file and cat that.
    aws s3api delete-objects --bucket ${BUCKET} --delete $delete_cmd > /tmp/delete_result.json
    cat /tmp/delete_result.json
  else
    echo "INFO: No log files match age ${PRUNE}, nothing to prune."
  fi
fi

echo "INFO: Completed sync.sh PID $$ $(date)"
