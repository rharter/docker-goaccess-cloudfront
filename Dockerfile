FROM alpine:3.12
LABEL mainainer="Ryan Harter <ryan@ryanharter.com>"

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

# s6 overlay download
ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

RUN apk upgrade --update --no-cache \
		&& rm -rf /var/cache/apk/* \
		&& tar xzf /tmp/s6overlay.tar.gz -C / \
		&& rm /tmp/s6overlay.tar.gz

ENTRYPOINT [ "/init" ]

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