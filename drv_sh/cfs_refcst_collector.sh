#!/bin/sh
#------------------------------------------------------
# CFS collector is used to obtain CFS reforecast 
# products.
#                                    Zhenning LI
#                                    Sep 6, 2021
#------------------------------------------------------

#------------------------------------------------------
# USAGE: 
# 
# If use from external call:
#   sh gfs_slicer.sh $INIT_YYYYMMDDHH $ARCH_PATH $FCST_DAYS
#   e.g. sh gfs_slicer.sh /home/metctm1/array/data 2021070512 1
#    
# Or you could remove the comment # from defined variables and
# assign them properly, just type: sh gfs_slicer.sh
#------------------------------------------------------

#https://www.ncei.noaa.gov/data/climate-forecast-system/access/operational-9-month-forecast/6-hourly-by-pressure/2021/202109/20210901/2021090100/pgbf2021090100.01.2021090100.grb2
#https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast/6-hourly-by-pressure-level-9-month-runs/
#https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast/6-hourly-flux-9-month-runs/2010/201007/20100705/
# ------------Below for user-defined configurations ------------

# Initial time 
# every five days 20100705 
STRT_YMDH=$1
#STRT_YMDH=2010070500

# Archive path
ARCH_PATH=$2
#ARCH_PATH=/home/metctm1/array/data/cfsv2/refcst/$STRT_YMDH

if [ ! -d $ARCH_PATH ]; then
    mkdir $ARCH_PATH
fi

# How long period to fecth
FCST_DAY=$3
#FCST_DAY=1

# ------------Upper for user-defined configurations ------------
# The interval to fetch GFS output, 3-hr preferred, 

# 1-hr minimum, and no longer than 6-hr.
FRQ=6

TOTAL_HR=`expr $FCST_DAY \* 24`

BASE_URL="https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast/6-hourly-by-pressure-level-9-month-runs/"
YYYY=${STRT_YMDH:0:4}
YYYYMM=${STRT_YMDH:0:6}
YYYYMMDD=${STRT_YMDH:0:8}
BASE_URL=$BASE_URL/${YYYY}/${YYYYMM}/${YYYYMMDD}/

BASE_SF_URL="https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast/6-hourly-flux-9-month-runs/"
BASE_SF_URL=$BASE_SF_URL/${YYYY}/${YYYYMM}/${YYYYMMDD}/

for CURR_HR in $(seq 0 $FRQ $TOTAL_HR) 
do
    
    CURR_TS=`date -d "${YYYYMMDD} ${STRT_YMDH:9:11} +${CURR_HR} hours" +%Y%m%d%H`
    FN_FILTER="pgbf"${CURR_TS}".01."${STRT_YMDH}".grb2"
    
    SRC_URL=${BASE_URL}${FN_FILTER} 
    wget ${SRC_URL} -O ${ARCH_PATH}/${FN_FILTER}

    FN_FILTER="flxf"${CURR_TS}".01."${STRT_YMDH}".grb2"
    SRC_URL=${BASE_SF_URL}${FN_FILTER} 
    wget ${SRC_URL} -O ${ARCH_PATH}/${FN_FILTER}

done 
