# create temp folder (if does not exists)
mkdir data\nomads_ncep_noaa
# get last forecast and historical info
docker run -v %cd%\data\nomads_ncep_noaa:\tmp\datastore -v %cd%\config.sh:\scripts\config.sh -i -t --name ncep-weather-worker geotekne/ncep-weather-worker:1.0.1
# remove docker container
docker rm ncep-weather-worker
