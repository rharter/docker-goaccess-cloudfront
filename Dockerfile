FROM oznu/s6-alpine:latest
LABEL mainainer="Ryan Harter <ryan@ryanharter.com>"

ENV \
	# Fail if cont-init scripts exit with non-zero code.
	S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
	CRON="" \
	PUID="" \
	PGID="" \
	TZ=""

RUN apk add --no-cache \
 			goaccess \
 			nginx \
 			aws-cli \
 		&& rm -rf /var/cache/* \
 		&& mkdir /var/cache/apk

COPY root/ /