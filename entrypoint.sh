#!/bin/sh
echo 'Create folder for images in case it does not exists'
mkdir -p /tmp/datastore/images
# run update at initialization
echo 'Running weather update process at startup'
/scripts/update-weather.sh

