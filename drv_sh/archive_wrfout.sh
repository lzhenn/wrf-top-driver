#!/bin/sh

INIT_DATE=${1}
WRF_DIR=${2}
ARCH_ROOT=${3}

if [ ! -d "${ARCH_ROOT}" ]; then
    mkdir ${ARCH_ROOT}
fi
mv ${WRF_DIR}/wrfout* ${ARCH_ROOT}/
mv ${WRF_DIR}/wrfx* ${ARCH_ROOT}/

