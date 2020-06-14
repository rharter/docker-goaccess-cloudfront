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

if [ ! -d /config/html ]; then
  mkdir -p /config/html
  chown -R "${PUID}:${PGID}" /config/html
fi

if [ ! -d /config/data ]; then
  mkdir -p /config/data
  chown -R "${PUID}:${PGID}" /config/data
fi

if [ ! -f /config/nginx.conf ]; then
	echo "Copying default nginx.conf file to /config/nginx.conf"
	cp /defaults/nginx.conf /config/nginx.conf
	chown -R "${PUID}:${PGID}" /config/nginx.conf
fi

echo "Running initial sync"
exec s6-setuidgid "${PUID}:${PGID}" /usr/bin/flock -n /app/sync.lock /app/sync.sh
