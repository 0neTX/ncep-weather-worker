FROM ghcr.io/osgeo/gdal:alpine-normal-latest
LABEL maintainer="one_tx@hotmail.com"

RUN apk add --update --no-cache curl coreutils && rm -rf /var/cache/apk/*
RUN adduser -h /home/worker -s /bin/sh -D worker
RUN echo -n 'worker:worker' | chpasswd

COPY ./scripts /scripts
COPY ./entrypoint.sh /

RUN mkdir /logs &&  chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
