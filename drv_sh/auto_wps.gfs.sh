#!/bin/sh

echo $@

STRT_DATE=${1}
END_DATE=${2}
NDAYS=${3}
STRT_HR=${4}
END_HR=${5}
DRVDIR=${6}
WPSDIR=${7}

# date parser
LID_NLS=$STRT_DATE
LID_NLE=$END_DATE

LOGFILE=wps.log
echo ">>>>WRF-WPS: ${LID_NLS} to ${LID_NLE}"

############## WPS ##################
cd $WPSDIR 
# Clean WPS data

echo ">>>>WRF-WPS:Clean Pre-existed Files..."
rm -f met_em.*
rm -f GFS:*
rm -f CFS:*
rm -f ERA:*
rm -f SST:*


# Process GFS

## Modify date and GFS
sed -i "/prefix/s/^.*/ prefix = 'GFS',/g" namelist.wps
sed -i "/start_date/s/^.*$/ start_date = '${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00',/g" namelist.wps
sed -i "/end_date/s/^.*$/ end_date = '${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00',/g" namelist.wps

echo ">>>>WRF-WPS:Working on WPS->Ungrib GFS..."
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
./link_grib.csh $DRVDIR/* #YYYYMMDD style
./ungrib.exe >& $LOGFILE

## Modify  GFS SST
echo ">>>>WRF-WPS:Working on WPS->Ungrib SST..."
sed -i "/prefix/s/^.*/ prefix = 'SST',/g" namelist.wps

ln -sf ungrib/Variable_Tables/Vtable.SST Vtable
./ungrib.exe >& $LOGFILE

echo ">>>>WRF-WPS:Working on WPS->Metgrid..."
sed -i "/fg_name/s/^.*/ fg_name = 'GFS', 'SST',/g" namelist.wps
mpirun -np 16 ./metgrid.exe >& $LOGFILE

