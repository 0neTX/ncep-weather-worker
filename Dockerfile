FROM geotekne/gdal-worker:2.1.4-alpine
LABEL maintainer="geotekne.argentina@gmail.com"

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22

RUN mkdir /logs
COPY ./scripts /scripts
COPY entrypoint.sh /
