#!/usr/bin/with-contenv sh

if [ -n "${NO_SERVER}" ] && [ -z "${CRON}" ]; then
  echo "
INFO: Server disabled via NO_SERVER environment variable, and no CRON schedule specified. Finishing container.
"
  exit 1
fi

