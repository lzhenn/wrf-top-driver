#/usr/bin/env python3
'''
Date: Dec 30, 2022 
This is the script to read conf/config.ana.ini and
rewrite conf/config.ini for the analysis run

Revision:
Dec 30, 2022 --- MVP v0.01 completed

Zhenning LI
'''
import os, sys
import datetime
import pandas as pd
import lib 
from utils import utils

CWD=sys.path[0]

CASE_FILE='db/cases.csv'

def main_run():
   # get the start and end date
   
    utils.write_log('Read Config...')    
    # controller config handler
    cfg=lib.cfgparser.read_cfg(CWD+'/conf/config.sample.ini')

    df_cases=pd.read_csv(CWD+'/'+CASE_FILE)

    # loop through the date
    for idx, itm in df_cases.iterrows():
        start_date=datetime.datetime.strptime(str(itm['Start(yyyymmddhh)']), '%Y%m%d%H')
        end_date=datetime.datetime.strptime(str(itm['End(yyyymmddhh)']), '%Y%m%d%H')
        # archive target dir
        tgt_dir=cfg['POSTPROCESS']['archive_root']+str(itm['End(yyyymmddhh)'])
        cfg['INPUT']['model_init_ts']=start_date.strftime('%Y%m%d%H')
        cfg['INPUT']['model_end_ts']=end_date.strftime('%Y%m%d%H')
        
        lib.cfgparser.write_cfg(cfg, CWD+'/conf/config.ini')
        print('********MULTI_CASE_DRIVER:Run WRF for case: %s********'%str(itm['Name']))
        os.system('python3 '+CWD+'/serial_driver.py ')        
        #break

if __name__=='__main__':
    main_run()
