#!/bin/sh
echo '-------------- Updating weather datastores ------------------'
date
cd $(dirname $0)
# execute scripts
./get-last-forecast-grib.sh
./get-last-historical-grib.sh

# move generated files into docker mapped folder
echo 'Move forecast generated file to mapped folder'
cp ./forecast/gfs-forecast.grb /tmp/datastore/images/

echo 'Move historical generated file to mapped folder'
mv ./historical/gfs-atmos-wave.*.grb /tmp/datastore/images/

date
echo '-------------- Weather datastores update finished------------------'


