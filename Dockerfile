FROM oznu/s6-alpine:3.11
LABEL mainainer="Ryan Harter <ryan@ryanharter.com>"

ENV \
	# Fail if cont-init scripts exit with non-zero code.
	S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
	CRON="" \
	PUID="" \
	PGID="" \
	TZ=""

RUN echo @edge http://nl.alpinelinux.org/alpine/edge/community > /etc/apk/repositories \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
 		&& apk add --no-cache \
 			goaccess@edge \
 			nginx@edge \
 			aws-cli@edge \
 		&& rm -rf /var/cache/* \
 		&& mkdir /var/cache/apk

COPY root/ /