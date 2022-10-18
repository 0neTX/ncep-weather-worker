#!/bin/sh
# include config variables
source ./config.sh 
# override config variables
# WEATHER VARIABLES
varatmos=$C_varatmos
varwave=$C_varwave
# REGION OF INTEREST
atmossubregion=$C_atmossubregion
wavesubregion=$C_wavesubregion
# TIMEFRAME
# fixed since we get only the lastest forecast as historical data
predictionslist="f000"

# GFS ATMOS
gfsatmos="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl"
# GFS WAVE
gfswave="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfswave.pl"

# working folder
workingfolder="./historical"
mkdir -p $workingfolder

# create temp folder just to download files
tmpfolder=temp-$(date +"%s")
mkdir $workingfolder/$tmpfolder

# grib filename prefix destination
destination_prefix="gfs-atmos-wave."

# yyyymmdd - today (-6 hs, to avoid use case where change on day generates a gap between availability of getting forecast/files and generation of them)
ddate=$(date -d '6 hour ago' +"%Y%m%d")
# forecast at 00, 06, 12, 18 hs
# need to determine which one is the forecast time
# need to review available website folders at something like this https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20220323/ and get the last available hour
availableforecasts=$(curl -s https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$ddate/)
dhour00=$(echo $availableforecasts | grep -c 'href="00')
dhour06=$(echo $availableforecasts | grep -c 'href="06')
dhour12=$(echo $availableforecasts | grep -c 'href="12')
dhour18=$(echo $availableforecasts | grep -c 'href="18')
dhour="00"

if [[ $dhour18 = "0" ]]; then
	if [[ $dhour12 = "0" ]]; then
		if [[ $dhour06 = "0" ]]; then
			dhour="00"
		else
			dhour="06"
		fi
	else
		dhour="12"
	fi
else
	dhour="18"
fi

# not to use the last one, just use the previous one (6 hours before), to avoid troubles between generation and consumption processes
if [[ $dhour = "00" ]]; then
	# need to modify the day (to previous one), and get last forecast (18hs)
	ddate=$(date -d '24 hour ago' +"%Y%m%d")
        dhour="18"
else
	# keep the day but change the time to previous
	if [[ $dhour = "06" ]]; then
		dhout="00"
	else
		if [[ $dhour = "12" ]]; then
			dhour="06"
		else
			dhour="12"
		fi
	fi
fi

# dir atmos
diratmos="%2Fgfs.$ddate%2F$dhour%2Fatmos"
# dir wave
dirwave="%2Fgfs.$ddate%2F$dhour%2Fwave%2Fgridded"
# iterate the string variable using for loop
for prediction in $predictionslist; do
	# file atmos
	fileatmos="gfs.t$dhour""z.pgrb2.0p25.$prediction"
	# file wave
	filewave="gfswave.t$dhour""z.global.0p25.$prediction.grib2"

	echo "--------- Download files from GFS ($prediction) ------------"
	# GFS ATMOS
	atmosurl="$gfsatmos?file=$fileatmos&$varatmos&$atmossubregion&dir=$diratmos"
        echo "---> downloading atmos-forecast-$ddate-$dhour-$prediction.grb"
	#echo $atmosurl
	curl --silent $atmosurl --output $workingfolder/$tmpfolder/atmos-forecast-$ddate-$dhour-$prediction.grb
        # checkfile with gdalinfo
	gdalinfo $workingfolder/$tmpfolder/atmos-forecast-$ddate-$dhour-$prediction.grb > /dev/null 2>&1
	if [[ $? = 1 ]]; then
		echo "ERROR: "atmos-forecast-$ddate-$dhour-$prediction.grb" is not recognized as a valid GRIB file"
	else
		echo "INFO: "atmos-forecast-$ddate-$dhour-$prediction.grb" download is ok"
	fi

	# GFS WAVE
	waveurl="$gfswave?file=$filewave&$varwave&$wavesubregion&dir=$dirwave"
        echo "---> downloading wave-forecast-$ddate-$dhour-$prediction.grb"
	#echo $waveurl
	curl --silent $waveurl --output $workingfolder/$tmpfolder/wave-forecast-$ddate-$dhour-$prediction.grb
        # checkfile with gdalinfo
	gdalinfo $workingfolder/$tmpfolder/wave-forecast-$ddate-$dhour-$prediction.grb > /dev/null 2>&1
	if [[ $? = 1 ]]; then
		echo "ERROR: "wave-forecast-$ddate-$dhour-$prediction.grb" is not recognized as a valid GRIB file"
	else
		echo "INFO: "wave-forecast-$ddate-$dhour-$prediction.grb" download is ok"
	fi

	# merge downloaded ATMOS and WAVE files into the full resulting file for the day/time 
	echo "INFO: Creating one GRIB file for the day/time"
	cat $workingfolder/$tmpfolder/atmos-forecast-$ddate-$dhour-$prediction.grb $workingfolder/$tmpfolder/wave-forecast-$ddate-$dhour-$prediction.grb > $workingfolder/$destination_prefix$ddate-$dhour.'grb'

done
rm -rf $workingfolder/$tmpfolder

