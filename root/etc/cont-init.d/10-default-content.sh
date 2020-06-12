#!/usr/bin/with-contenv sh

if [ ! -d /logs ]; then
	echo "
ERROR: '/logs' directory must be mounted
"
	exit 1
fi

if [ ! -d /config ]; then
	echo "
ERROR: '/config' directory must be mounted
"
	exit 1
fi

mkdir -p /config/html

if [ ! -f /config/nginx.conf ]; then
	echo "Copying default nginx.conf file to /config/nginx.conf"
	cp /opt/nginx.conf /config/nginx.conf
fi

echo "Running initial sync"
/usr/bin/flock -n /app/sync.lock /app/sync.sh
