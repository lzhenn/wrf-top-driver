#/usr/bin/env python3
'''
Date: Jun 13, 2022 
This is the script to read conf/config.ana.ini and
rewrite conf/config.ini for the analysis run

Revision:
June 13,  2022 --- MVP v0.01 completed

Zhenning LI
'''
import os, sys
import datetime
import pandas as pd
import lib 
from utils import utils

CWD=sys.path[0]

# ----------------------- MAIN SETTINGS-----------------------
STRTYMD='20210909'
ENDYMD='20210918'
# How long is each span of the analysis run in days
ANA_LEN=2
# ----------------------- MAIN SETTINGS-----------------------


def main_run():
    # one more day for spin-up
    span_len=ANA_LEN+1
    # get the start and end date
    start_date=datetime.datetime.strptime(STRTYMD, '%Y%m%d')
    end_date=datetime.datetime.strptime(ENDYMD, '%Y%m%d')
    curr_date=start_date
    
    utils.write_log('Read Config...')    
    # controller config handler
    cfg=lib.cfgparser.read_cfg(CWD+'/conf/config.ana.ini')
    # archive target dir
    tgt_dir=cfg['POSTPROCESS']['archive_root']+start_date.strftime('%Y%m%d%H')
    
    # loop through the date
    while curr_date<end_date+datetime.timedelta(days=-1):
        cfg['INPUT']['model_init_ts']=curr_date.strftime('%Y%m%d%H')
        cfg['INPUT']['model_run_days']=str(span_len)
        #lib.cfgparser.write_cfg(cfg, CWD+'/conf/config.ini')
        #os.system('python3 '+CWD+'/top_driver.py ')
        # link ensuing files
        if curr_date>start_date:
            src_dir=cfg['POSTPROCESS']['archive_root']+curr_date.strftime('%Y%m%d%H')
            lk_strt_time=curr_date+datetime.timedelta(hours=25)
            lk_end_time=curr_date+datetime.timedelta(days=span_len)
            time_stamps=pd.date_range(lk_strt_time, lk_end_time, freq='H')
            for ts in time_stamps:
                src_file='wrfout_d0?_%s' % ts.strftime('%Y-%m-%d_%H:%M:%S')
                print('ln -s '+src_dir+'/'+src_file+' '+tgt_dir+'/')
                os.system('ln -s '+src_dir+'/'+src_file+' '+tgt_dir+'/')
        curr_date=curr_date+datetime.timedelta(days=ANA_LEN)


if __name__=='__main__':
    main_run()
