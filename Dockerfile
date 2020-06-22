FROM alpine:edge AS build
RUN apk add --no-cache \
    autoconf \
    automake \
    build-base \
    clang \
    clang-static \
    gettext-dev \
    gettext-static \
    git \
    libmaxminddb-dev \
    libressl-dev \
    linux-headers \
    ncurses-dev \
    ncurses-static \
    tzdata \
    wget

WORKDIR /goaccess
RUN wget https://tar.goaccess.io/goaccess-1.4.tar.gz \
    && tar -xzf goaccess-1.4.tar.gz

WORKDIR /goaccess/goaccess-1.4
RUN autoreconf -fiv \
    && CC="clang" CFLAGS="-O3 -static" LIBS="$(pkg-config --libs openssl)" ./configure --prefix="" --enable-utf8 --with-openssl --enable-geoip=mmdb \
    && make \
    && make DESTDIR=/dist install

FROM oznu/s6-alpine:3.12
LABEL mainainer="Ryan Harter <ryan@ryanharter.com>"

ENV \
  # Fail if cont-init scripts exit with non-zero code.
  S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  CRON="" \
  PUID="" \
  PGID="" \
  TZ="" \
  HEALTHCHECK_ID="" \
  GOACCESS_ARGS=

RUN apk add --no-cache \
      nginx \
      aws-cli \
      curl \
    && rm -rf /var/cache/* \
    && mkdir /var/cache/apk

COPY --from=build /dist /
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo

COPY root/ /
