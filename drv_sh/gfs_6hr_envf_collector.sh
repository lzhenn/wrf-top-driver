#!/bin/sh
#------------------------------------------------------
# GFS Slicer using NOAA grib filter to extract
# orginal GFS 0d25 products within domains of interests 
# and variables for driving PATH system. 95% space can 
# be saved compared with original global data.
#
#                                    Zhenning LI
#                                   July 1, 2021
#------------------------------------------------------

# ------------Below for user-defined configurations ------------
# Start time 
STRT_YMDH=$1
#STRT_YMDH=2021062712

# Archive path
ARCH_PATH=$2
#ARCH_PATH=/home/lzhenn/array74/Njord_Calypso/drv_field/gfs/2021062712

# How long period to fecth
FCST_DAY=$3
#FCST_DAY=1

# The interval to fetch GFS output, 3-hr preferred, 
# 1-hr minimum, and no longer than 6-hr.
FRQ=6

LON_LEFT=95
LON_RIGHT=135
LAT_TOP=40
LAT_BOTTOM=5

# ------------Upper for user-defined configurations ------------

FCST_DAY=`expr $FCST_DAY + 1`
FETCH_DAY=$(date -d "${STRT_YMDH:0:8}" +%Y%m%d)
TODAY=$(date +%Y%m%d)
TIME_DELTA=`expr $TODAY - $FETCH_DAY`

if [ ! -d $ARCH_PATH ]; then
    mkdir $ARCH_PATH
fi

# not realtime, try get from envf server

rm -rf $ARCH_PATH/*f000*
if [ $TIME_DELTA -gt 5 ]; then
    CURR_DATE=$FETCH_DAY
    ADD_DAY=0
    while [ $ADD_DAY -lt $FCST_DAY ]
    do
        BASE_URL="/home/dataop/archive/vol001/ncep/gfs_0.25deg_archive/${CURR_DATE:0:4}/${CURR_DATE:0:6}/${CURR_DATE:0:8}/"
        echo $BASE_URL
        ln -sf $BASE_URL/*f000* $ARCH_PATH/ 
        ADD_DAY=`expr $ADD_DAY + 1`
        CURR_DATE=$(date -d "${STRT_YMDH:0:8} +${ADD_DAY}day" +%Y%m%d)
    done
fi

