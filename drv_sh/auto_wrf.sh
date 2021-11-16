#!/bin/sh

echo $@

STRT_DATE=${1}
END_DATE=${2}
NDAYS=${3}
INIT_HR=${4}
END_HR=${5}
WPS_DIR=${6}
WRF_DIR=${7}
REAL_FLAG=${8}
WRF_FLAG=${9}
NTASK=${10}
# date parser
LID_NLS=$STRT_DATE
LID_NLE=$END_DATE


LOGFILE=wps.log
echo "Simulating ${LID_NLS} to ${LID_NLE}"

STRT_DATE_PACK=${STRT_DATE//-/} # YYYYMMDD style
END_DATE_PACK=${END_DATE//-/}

# date parser
LID_NLS=$STRT_DATE
LID_NLE=$END_DATE

YYYY_NLS=${STRT_DATE_PACK:0:4} # 2040
YYYY_NLE=${END_DATE_PACK:0:4}

MM_NLS=${STRT_DATE_PACK:4:2} # 08
MM_NLE=${END_DATE_PACK:4:2}

DD_NLS=${STRT_DATE_PACK:6:2} # 10
DD_NLE=${END_DATE_PACK:6:2}

echo ">>>>WRF-REAL:Clean Pre-existed Files..."
cd $WRF_DIR

sed -i "/run_days/s/^.*$/ run_days                          = ${NDAYS},/g" namelist.input
sed -i "/start_year/s/^.*$/ start_year                          = ${YYYY_NLS}, ${YYYY_NLS}, ${YYYY_NLS}, ${YYYY_NLS},/g" namelist.input
sed -i "/start_year/s/^.*$/ start_year                          = ${YYYY_NLS}, ${YYYY_NLS}, ${YYYY_NLS}, ${YYYY_NLS},/g" namelist.input
sed -i "/end_year/s/^.*$/ end_year                            = ${YYYY_NLE}, ${YYYY_NLE}, ${YYYY_NLE}, ${YYYY_NLE},/g" namelist.input
sed -i "/start_month/s/^.*$/ start_month                          = ${MM_NLS}, ${MM_NLS}, ${MM_NLS}, ${MM_NLS},/g" namelist.input
sed -i "/end_month/s/^.*$/ end_month                          = ${MM_NLE}, ${MM_NLE}, ${MM_NLE}, ${MM_NLE},/g" namelist.input
sed -i "/start_day/s/^.*$/ start_day                          = ${DD_NLS}, ${DD_NLS}, ${DD_NLS}, ${DD_NLS},/g" namelist.input
sed -i "/end_day/s/^.*$/ end_day                          = ${DD_NLE}, ${DD_NLE}, ${DD_NLE}, ${DD_NLE},/g" namelist.input
sed -i "/start_hour/s/^.*$/ start_hour                          = ${INIT_HR}, ${INIT_HR}, ${INIT_HR}, ${INIT_HR},/g" namelist.input
sed -i "/end_hour/s/^.*$/ end_hour                          = ${END_HR}, ${END_HR}, ${END_HR}, ${END_HR},/g" namelist.input
date
#-----------------REAL---------------------
if [ $REAL_FLAG == 1 ]; then

    rm -f met_em.d0*
    rm -f wrfinput_d0*
    rm -f wrflowinp_d0*
    rm -f wrfbdy_d0*
    rm -f wrffda*

    echo ">>>>WRF-REAL: Run real.exe..."
    ln -sf $WPS_DIR/met_em.d0* ./
    mpirun -np 16 ./real.exe
fi
date

#-----------------WRF---------------------
if [ $WRF_FLAG == 1 ]; then
    echo ">>>>WRF-WRF: Run wrf.exe..."
    cd $WRF_DIR
    mpirun -np $NTASK ./wrf.exe
fi
echo ">>>>ALL DONE!!!"
date

