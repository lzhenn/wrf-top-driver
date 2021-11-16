# Set up Constants
date
echo $@
SNAME=$1
NODE=$2
NCPU=$3
NQUE=$4
let NTASK=NCPU/NQUE
STRT_DATE=${5}
END_DATE=${6}
NDAYS=${7}
WPS_FLAG=$8
REAL_FLAG=$9
WRF_FLAG=${10}
QUEUE=${11}

ARCH=${12}

if [ $ARCH = "Intel" ]; then
    source ~/.bashrc
else
    source ~/.bashrc_pgi20_amd
fi    


# script dir
WRKD=/home/metctm1/array/workspace/cmip6-to-wrfinterm/
# restart archive
ARCD=/home/metctm1/array_hq132/cmip6-wrf-arch/ssp585/

CMIP_DIR=/home/metctm1/array/data/cmip6/wrf_mid/$SNAME

echo $QUEUE
WPS_DIR=/home/metctm1/array_${NODE}/WPS_${QUEUE}/
WRF_DIR=/home/metctm1/array_${NODE}/WRFV3_${QUEUE}/run


INIT_HR="00"
END_HR="00"
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


LOGFILE=wps.log

#-----------------WPS---------------------
if [ $WPS_FLAG == 1 ]; then
    echo ">>>>WRF-WPS: ${LID_NLS} to ${LID_NLE}"
    cd $WPS_DIR
    rm -f geo_em*
    cp ${WRKD}/db/2050/geo_em* $WPS_DIR
    cp ${WRKD}/db/namelist.wps $WPS_DIR
    # Clean WPS data

    echo ">>>>WRF-WPS:Clean Pre-existed Files..."
    rm -f met_em.*
    rm -f GFS:*
    rm -f ERA*
    rm -f CMIP*
    rm -f SST:*

    # Process CMIP 

    sed -i "/prefix/s/^.*/ prefix = 'CMIP',/g" namelist.wps
    sed -i "/start_date/s/^.*$/ start_date = '${LID_NLS}_${INIT_HR}:00:00','${LID_NLS}_${INIT_HR}:00:00','${LID_NLS}_${INIT_HR}:00:00','${LID_NLS}_${INIT_HR}:00:00',/g" namelist.wps
    sed -i "/end_date/s/^.*$/ end_date = '${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00','${LID_NLE}_${END_HR}:00:00',/g" namelist.wps

    ln -sf ${CMIP_DIR}/CMIP:${YYYY_NLS}* ./
    echo ">>>>WRF-WPS:Working on WPS->Metgrid..."
    #./metgrid.exe >& $LOGFILE
    mpirun -np 8 ./metgrid.exe >& $LOGFILE
fi
date

#-----------------REAL---------------------
if [ $REAL_FLAG == 1 ]; then
    echo ">>>>WRF-REAL:Clean Pre-existed Files..."
    cd $WRF_DIR
    cp ${WRKD}/db/namelist.input $WRF_DIR
    cp ${WRKD}/db/VEGPARM.TBL $WRF_DIR

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
    cp ${ARCD}/${YYYY_NLS}/wrfrst_d0?_${YYYY_NLS}-${MM_NLS}-${DD_NLS}_00:00:00 $WRF_DIR
    mpirun -np $NTASK ./wrf.exe
fi
echo ">>>>ALL DONE!!!"
date
