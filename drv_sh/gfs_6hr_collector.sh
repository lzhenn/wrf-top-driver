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
#STRT_YMDH=2022012612

# Archive path
ARCH_PATH=$2
#ARCH_PATH=/home/lzhenn/array74/Njord_Calypso/drv_field/gfs/2022012612

# How long period to fecth
FCST_DAY=$3
#FCST_DAY=1

# The interval to fetch GFS output, 3-hr preferred, 
# 1-hr minimum, and no longer than 6-hr.
FRQ=6

# Resolution: 0p50, 0p25
RES=0p50

LON_LEFT=95
LON_RIGHT=135
LAT_TOP=40
LAT_BOTTOM=5

# try time interval in seconds
TRY_INTERVAL=90

# ------------Upper for user-defined configurations ------------

FETCH_DAY=$(date -d "${STRT_YMDH:0:8}" +%Y%m%d)
TODAY=$(date +%Y%m%d)
TIME_DELTA=`expr $TODAY - $FETCH_DAY`
echo $FETCH_DAY----$TODAY
echo $TIME_DELTA
if [ ! -d $ARCH_PATH ]; then
    mkdir $ARCH_PATH
fi

# not realtime, try get from envf server
if [ $TIME_DELTA -gt 5 ]; then
    echo "not realtime, exit"
    exit
    CURR_DATE=$FETCH_DAY
    ADD_DAY=0
    while [ $ADD_DAY -lt $FCST_DAY ]
    do
        BASE_URL="/home/dataop/archive/vol001/ncep/gfs_0.25deg_archive/${CURR_DATE:0:4}/${CURR_DATE:0:6}/${CURR_DATE:0:8}/"
        echo $BASE_URL
        #ln -s $BASE_URL/*f000* ./
        ADD_DAY=`expr $ADD_DAY + 1`
        CURR_DATE=$(date -d "${STRT_YMDH:0:8} +${ADD_DAY}day" +%Y%m%d)
    done
fi

TOTAL_HR=`expr $FCST_DAY \* 24`


# fetch from ncep server

BASE_URL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_"$RES".pl"


LV_FILTER="&lev_0-0.1_m_below_ground=on&lev_0.1-0.4_m_below_ground=on&lev_0.4-1_m_below_ground=on"
LV_FILTER=${LV_FILTER}"&lev_1000_mb=on&lev_100_mb=on&lev_10_m_above_ground=on&lev_10_mb=on"
LV_FILTER=${LV_FILTER}"&lev_1-2_m_below_ground=on&lev_150_mb=on&lev_15_mb=on&lev_1_mb=on"
LV_FILTER=${LV_FILTER}"&lev_200_mb=on&lev_20_mb=on&lev_250_mb=on&lev_2_m_above_ground=on"
LV_FILTER=${LV_FILTER}"&lev_2_mb=on&lev_300_mb=on&lev_30_mb=on&lev_350_mb=on&lev_3_mb=on"
LV_FILTER=${LV_FILTER}"&lev_400_mb=on&lev_40_mb=on&lev_450_mb=on&lev_500_mb=on&lev_50_mb=on"
LV_FILTER=${LV_FILTER}"&lev_550_mb=on&lev_5_mb=on&lev_600_mb=on&lev_650_mb=on&lev_700_mb=on"
LV_FILTER=${LV_FILTER}"&lev_70_mb=on&lev_750_mb=on&lev_7_mb=on&lev_800_mb=on&lev_850_mb=on"
LV_FILTER=${LV_FILTER}"&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&lev_max_wind=on"
LV_FILTER=${LV_FILTER}"&lev_mean_sea_level=on&lev_surface=on&lev_tropopause=on"

VAR_FILTER="&var_CICEP=on&var_HGT=on&var_LAND=on&var_MSLET=on&var_POT=on&var_PRES=on"
VAR_FILTER=${VAR_FILTER}"&var_PRMSL=on&var_RH=on&var_SNMR=on&var_SNOD=on&var_SOILL=on"
VAR_FILTER=${VAR_FILTER}"&var_SOILW=on&var_TMP=on&var_TSOIL=on&var_UGRD=on&var_VGRD=on&var_WEASD=on"

DOMAIN_FILTER="&subregion=&leftlon="${LON_LEFT}"&rightlon="${LON_RIGHT}"&toplat="${LAT_TOP}"&bottomlat="${LAT_BOTTOM}

TS_FILTER="&dir=%2Fgfs."${STRT_YMDH:0:8}"%2F"${STRT_YMDH:8}"%2Fatmos"

for CURR_HR in $(seq 0 $FRQ $TOTAL_HR) 
do
    TRY_TIME=10

    TSTEP=`printf "%03d" $CURR_HR`
    if [ $RES == "0p25"]; then
        FN_FILTER="?file=gfs.t"${STRT_YMDH:8}"z.pgrb2.0p25.f"${TSTEP}
        NOM_SIZE=6000000
    else
        FN_FILTER="?file=gfs.t"${STRT_YMDH:8}"z.pgrb2full.0p50.f"${TSTEP}
        NOM_SIZE=1000000
    fi
    SRC_URL=${BASE_URL}${FN_FILTER}${LV_FILTER}${VAR_FILTER}${DOMAIN_FILTER}${TS_FILTER}
    
    while (( $TRY_TIME>0 ))
    do
        wget ${SRC_URL} -O ${ARCH_PATH}/${FN_FILTER:6}
        if [[ "$?" == 0 ]]; then
            FILESIZE=$(stat -c%s "${ARCH_PATH}/${FN_FILTER:6}")
            if (( $FILESIZE<$NOM_SIZE )); then
                echo "File size not correct, try again in "$TRY_INTERVAL"s..."
                TRY_TIME=`expr $TRY_TIME - 1`
                sleep $TRY_INTERVAL
            else
                break
            fi
        else
            echo "Error downloading file, try again in "$TRY_INTERVAL"s..."
            TRY_TIME=`expr $TRY_TIME - 1`
            sleep $TRY_INTERVAL
        fi
    done
    if (( $TRY_TIME == 0)); then
        echo "Download "${ARCH_PATH}/${FN_FILTER:6} "failed after maximum attampts!!!"
    fi
done 
