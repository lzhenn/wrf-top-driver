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


LOGFILE=wps.log
echo "Simulating ${LID_NLS} to ${LID_NLE}"

############## WPS ##################
cd $WPSDIR 

# Clean WPS data
echo "Clean WPS..."
rm -f met_em.*
rm -f GFS:*
rm -f CFS:*
rm -f ERA:*
rm -f SST:*

echo "Working on WPS..."

sed -i "/start_date/s/^.*$/ start_date = '${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00','${LID_NLS}_${STRT_HR}:00:00',/g" namelist.wps
sed -i "/end_date/s/^.*$/ end_date = '${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00',/g" namelist.wps

echo "Working on WPS->Ungrib CFSv2-pl..."
ln -sf ungrib/Variable_Tables/Vtable.CFSR Vtable
./link_grib.csh $ERADIR/pgbf*.grb2
sed -i "/prefix/s/^.*/ prefix = 'CFSPL',/g" namelist.wps
./ungrib.exe >& $LOGFILE
# Process CFSv2 single layer
./link_grib.csh $ERADIR/flxf*.grb2
## Modify to ERA single layer
echo "Working on WPS->Ungrib CFSv2-sl..."
sed -i "/prefix/s/^.*/ prefix = 'CFSSL',/g" namelist.wps
./ungrib.exe >& $LOGFILE

echo "Working on WPS->Metgrid..."
sed -i "/fg_name/s/^.*/ fg_name = 'CFSPL', 'CFSSL',/g" namelist.wps
mpirun -np 16 ./metgrid.exe >& $LOGFILE

