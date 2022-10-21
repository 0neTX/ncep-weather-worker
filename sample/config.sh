#!/bin/sh
# WEATHER VARIABLES
# atmos variables
C_varatmos="lev_10_m_above_ground=on&lev_10_m_above_mean_sea_level=on&lev_500_mb=on&lev_entire_atmosphere=on&lev_mean_sea_level=on&lev_surface=on&var_APCP=on&var_GUST=on&var_HGT=on&var_PRMSL=on&var_TCDC=on&var_TMP=on&var_UGRD=on&var_VGRD=on"
# wave variables 
C_varwave="var_HTSGW=on&var_WVDIR=on&var_WVPER=on"

# REGION OF INTEREST
# note: it's required to keep subregions separated since 
# wave GFS service is not cutting by subregion as atmos GFS service is doing (each grade in lon = 4 pixels). 
# differences between layers/bands size in rows/columns triggered errors while reading files
C_atmossubregion="subregion=&leftlon=-10&rightlon=28&toplat=45&bottomlat=32"
C_wavesubregion="subregion=&leftlon=-10&rightlon=27.75&toplat=45&bottomlat=32"

# TIMEFRAME
# Forecast files goes from f000 to f384 (1hs-to-1hs and 3hs-to-3hs depending on service/date)
# NOAA allows, first 5 days = 1to1 (120 requests), next days = 3to3
# Example: 0,6,12,18,24,30,36,42,48,60,72,84,96,108,120
# so mapping the example it would be requesting data from these files: f000,f006,f012,f018,f024,f030,f036,f042,f048,f060,f072,f084,f096,f108,f120
# then cycle all the elements on list (and finally concatenate all downloaded files)
# for the purpose of historical info, we only need to get the f000 file with stats (since it's the current status for the date/time)
C_predictionslist="f000 f006 f012 f018 f024 f030 f036 f042 f048 f060 f072 f084 f096 f108 f120"
