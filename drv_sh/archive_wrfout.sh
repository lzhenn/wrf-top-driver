#!/bin/sh

INIT_DATE=${1}
WRF_DIR=${2}
ARCH_ROOT=${3}

ARCHIVE=${ARCH_ROOT}/${INIT_DATE}

if [ ! -d "${ARCHIVE}" ]; then
    mkdir ${ARCHIVE}
fi
mv ${WRF_DIR}/wrfout* ${ARCHIVE}/

