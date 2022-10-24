#!/bin/sh
# create temp folder (if does not exists)
mkdir -p ./data/nomads_ncep_noaa
# get last forecast and historical info
docker run -v $(pwd)/data/nomads_ncep_noaa:/tmp/datastore -v $(pwd)/config.sh:/scripts/config.sh -i -t --name ncep-weather-worker geotekne/ncep-weather-worker:1.0.0 bash
# remove docker container
docker rm ncep-weather-worker
