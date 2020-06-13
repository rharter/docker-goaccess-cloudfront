#!/usr/bin/with-contenv sh

echo "INFO: Starting sync.sh PID $$ $(date)"

if [ -z "$BUCKET" ]; then
	echo "ERROR: Missing BUCKET environment variable."
	exit 1
fi

# sync the log bucket
echo "INFO: Syncing from bucket s3://${BUCKET}"
aws s3 sync s3://${BUCKET} /logs

echo "INFO: Generating analytics html from logs."
zcat /logs/*.gz | goaccess --log-format CLOUDFRONT -a -o /config/html/${HTML_FILENAME:-index}.html -

case "$POST_ACTION" in
	"" )
		;;

	"prune" )
		PRUNE=1
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
	let log_count=$(ls -l /logs | wc -l | awk '{$1=$1};1')-1
	let prune_count=log_count-1
	
	echo "INFO: Pruning ${prune_count} old logs."

	newest_log_filename=$(ls -tp /logs | head -n 1)
	find /logs/ -type f -not -name "${newest_log_filename}" -delete

	aws s3 sync /logs s3://${BUCKET} --delete
fi

echo "INFO: Completed sync.sh PID $$ $(date)"
