#!/bin/sh

echo $@

STRT_DATE=${1}
END_DATE=${2}
NDAYS=${3}
STRT_HR=${4}
END_HR=${5}
ERADIR=${6}
WPSDIR=${7}

# date parser
LID_NLS=$STRT_DATE
LID_NLE=$END_DATE

STRT_DATE_PACK=${STRT_DATE//-/} # YYYYMMDD style
END_DATE_PACK=${END_DATE//-/}



LOGFILE=wps.log
echo "Simulating ${LID_NLS} to ${LID_NLE}"

############## WPS ##################
cd $WPSDIR 

# Clean WPS data
echo "Clean WPS..."
rm -f met_em.*
rm -f GFS:*
rm -f CFS*
rm -f PFILE*
rm -f ERA*
rm -f SST:*

echo "Working on WPS..."

sed -i "/start_date/s/^.*$/ start_date = '${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00',/g" namelist.wps
sed -i "/end_date/s/^.*$/ end_date = '${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00',/g" namelist.wps

echo "Working on WPS->Ungrib ERA-pl..."
ln -sf ungrib/Variable_Tables/Vtable.ERA-interim.pl Vtable


# temp folder for era5 slices
if [ ! -d era5_tmp ]; then
    mkdir era5_tmp
fi
rm -f era5_tmp/*

# loop to fetch era5 data
CURR_DATE_PACK=$STRT_DATE_PACK
while [ ! $CURR_DATE_PACK == $END_DATE_PACK ]
do
    if [ ! -f $ERADIR/$CURR_DATE_PACK-pl.grib ]; then
        echo $ERADIR/$CURR_DATE_PACK-pl.grib not exist!
        exit
    fi
    if [ ! -f $ERADIR/$CURR_DATE_PACK-sl.grib ]; then
        echo $ERADIR/$CURR_DATE_PACK-sl.grib not exist!
        exit
    fi

    ln -sf $ERADIR/$CURR_DATE_PACK* ./era5_tmp/
    CURR_DATE_PACK=`date -d "$CURR_DATE_PACK +1 day " +%Y%m%d`
done 
ln -sf $ERADIR/$END_DATE_PACK* ./era5_tmp/

./link_grib.csh era5_tmp/*pl.grib

sed -i "/prefix/s/^.*/ prefix = 'ERAPL',/g" namelist.wps
./ungrib.exe >& $LOGFILE

# Process ERA single layer
./link_grib.csh era5_tmp/*sl.grib
## Modify to ERA single layer
echo "Working on WPS->Ungrib ERA-sl..."
sed -i "/prefix/s/^.*/ prefix = 'ERASL',/g" namelist.wps
./ungrib.exe >& $LOGFILE

echo "Working on WPS->Metgrid..."
sed -i "/fg_name/s/^.*/ fg_name = 'ERAPL', 'ERASL',/g" namelist.wps
mpirun -np 8 ./metgrid.exe >& $LOGFILE

