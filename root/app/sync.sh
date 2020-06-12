#!/usr/bin/with-contenv sh

echo "INFO: Starting sync.sh PID $$ $(date)"

if [ -z "$CRON" ]; then
	echo "Missing BUCKET environment variable."
	exit 1
fi

# sync the log bucket
echo "INFO: Syncing from bucket s3://${BUCKET}"
aws s3 sync s3://${BUCKET} /logs

echo "INFO: Generating analytics html from logs."
zcat /logs/*.gz | goaccess --log-format CLOUDFRONT -a -o /config/html/${HTML_FILENAME:-index}.html -

echo "INFO: Completed sync.sh PID $$ $(date)"
