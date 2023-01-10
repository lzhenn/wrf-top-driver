#/usr/bin/env python3
'''
Date: May 1, 2021 (Labour Day!)

This is the main script to drive the wrf top driver

Revision:
Oct 23, 2021 --- Fit for CFSv2
Aug 25, 2021 --- Revision
May 1,  2021 --- MVP v0.01 completed

Zhenning LI
'''
import os, sys, logging.config
import datetime
import lib 
from utils import utils

CWD=sys.path[0]

def main_run():
    
    # logging manager
    logging.config.fileConfig(CWD+'/conf/logging_config.ini')
    
    utils.write_log('Read Config...')
    
    # controller config handler
    cfg_hdl=lib.cfgparser.read_cfg(CWD+'/conf/config.ini')
 
    utils.write_log('Construct dispatcher...')
    
    ctrler=lib.dispatcher.Dispatcher(cfg_hdl)
 
    # drv downloader
    if cfg_hdl['DOWNLOAD'].getboolean('down_drv_data'):
        if cfg_hdl['INPUT']['drv_type'] == 'era5':
            ctrler.down_era5(cfg_hdl)
        else:
            CMDLINE='sh '+CWD+'/drv_sh/'+ctrler.drv_type+'_collector.sh' 
            CMDARGS=' %s %s %s'
            CMDLINE=CMDLINE+CMDARGS
            os.system(CMDLINE % (
                ctrler.start_time.strftime('%Y%m%d%H'),
                ctrler.raw_root, str(ctrler.ndays)))
    if ctrler.run_wps:
        ctrler.ctrl_run_wps()
    
    if (ctrler.run_real or ctrler.run_wrf):
        ctrler.ctrl_run_realwrf()
    
    if ctrler.archive:
        ctrler.ctrl_archive()


if __name__=='__main__':
    main_run()
