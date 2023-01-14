#/usr/bin/env python3
"""
    Build dispatcher to control the running flow

    Class       
    ---------------
                dispatcher
"""

import datetime
import os
import cdsapi
from utils import utils

print_prefix='lib.dispatcher>>'

CONST_DIC=utils.get_glb_const()

class Dispatcher:

    '''
    Construct dispatcher to control the running flow

    Attributes
    -----------
    start_t:        datetime obj
        model start time

    end_t:          datetime obj
        model end time
    
    Methods
    -----------

    '''
    
    def __init__(self, cfg):
        """ construct dispatcher obj """
        self.drv_type=cfg['INPUT']['drv_type']
        self.wps_root=cfg['INPUT']['wps_root']
        self.wrf_root=cfg['INPUT']['wrf_root']
        self.nml_temp=cfg['INPUT']['nml_temp']
        self.raw_root=cfg['INPUT']['raw_root']

        self.start_time=datetime.datetime.strptime(cfg['INPUT']['model_init_ts'],'%Y%m%d%H')
        if not (self.drv_type =='era5'):
            self.raw_root=cfg['INPUT']['raw_root']+'/'+self.start_time.strftime('%Y%m%d%H')
        try: 
            self.end_time=datetime.datetime.strptime(
                cfg['INPUT']['model_end_ts'],'%Y%m%d%H')
        except:
            self.ndays=int(cfg['INPUT']['model_run_days'])
            self.end_time=self.start_time+datetime.timedelta(days=self.ndays)

        self.nhours=int((self.end_time-self.start_time).total_seconds()/3600)
        self.run_wps=cfg['CORE'].getboolean('run_wps')
        self.run_real=cfg['CORE'].getboolean('run_real')
        self.run_wrf=cfg['CORE'].getboolean('run_wrf')
        self.nml_rewrite=cfg['CORE'].getboolean('rewrite_namelist')
        self.geo_rewrite=cfg['CORE'].getboolean('rewrite_geo_em')
        self.ntask=cfg['CORE']['ntask']

        self.archroot=utils.parse_fmt_timepath(
            self.start_time,cfg['POSTPROCESS']['archive_root'])
        self.archive=cfg['POSTPROCESS'].getboolean('arch_wrfout')
    
    def down_era5(self, cfg):
        ''' Download ERA5 pres and single lv data '''
        # Area: North/West/South/East
        c = cdsapi.Client()
        int_time_obj = self.start_time
        end_time_obj = self.end_time 
        file_time_delta=datetime.timedelta(days=1)
        curr_time_obj = int_time_obj


        os.system('mkdir '+self.raw_root)
        
        while curr_time_obj <= end_time_obj:
            
            utils.write_log(print_prefix+'download single layer: %s' % curr_time_obj.strftime('%Y%m%d')) 
            
            # single layer data retriever
            c.retrieve(
                'reanalysis-era5-single-levels',
                {
                    'product_type':'reanalysis',
                    'format':'grib',
                    'variable':CONST_DIC['ERA5_SL_VARS'],
                    'date':curr_time_obj.strftime('%Y%m%d'),
                    'area':cfg['DOWNLOAD']['area_nwse'],
                    'time':'00/to/23/by/3',
                },
                self.raw_root+'/'+curr_time_obj.strftime('%Y%m%d')+'-sl.grib')
            
            # multiple layer data retriever
            
            utils.write_log(print_prefix+'download multiple layers: %s' % curr_time_obj.strftime('%Y%m%d')) 
            c.retrieve(
                'reanalysis-era5-pressure-levels',
                {
                    'product_type':'reanalysis',
                    'format':'grib',
                    'pressure_level':CONST_DIC['ERA5_PL_LAYS'],
                    'date':curr_time_obj.strftime('%Y%m%d'),
                    'area':cfg['DOWNLOAD']['area_nwse'],
                    'time':'00/to/23/by/3',
                    'variable':CONST_DIC['ERA5_PL_VARS'],
                    },
                self.raw_root+'/'+curr_time_obj.strftime('%Y%m%d')+'-pl.grib')
            
            curr_time_obj=curr_time_obj+file_time_delta
        
    def ctrl_run_wps(self):
        """ run wps """
        # STRT_DATE=${1}
        arg=self.start_time.strftime('%Y-%m-%d')+' '
        # END_DATE=${2}
        arg=arg+self.end_time.strftime('%Y-%m-%d')+' '
        # STRT_HR=${3}
        arg=arg+self.start_time.strftime('%H')+' '
        # END_HR=${4}
        arg=arg+self.end_time.strftime('%H')+' '
        # ERADIR=${5}
        arg=arg+self.raw_root+' ' 
        # WPSDIR=${6}
        arg=arg+self.wps_root+' '
        if self.geo_rewrite:
            os.system('cp ./db/geo_em/'+self.nml_temp+'/* '+self.wps_root+'/')
        
        if self.nml_rewrite:
            nml_tmp='./db/nml_temp/'+self.nml_temp
            nml_tmp=nml_tmp+'/namelist.wps.'+self.drv_type

            os.system('cp '+nml_tmp+' '+self.wps_root+'/namelist.wps')
        
        os.system('sh ./drv_sh/auto_wps.'+self.drv_type+'.sh '+arg)

    def ctrl_run_realwrf(self):
        """ run wps """
        # 1
        arg=self.start_time.strftime('%Y-%m-%d')+' '
        # 2
        arg=arg+self.end_time.strftime('%Y-%m-%d')+' '
        # 3
        arg=arg+str(self.nhours)+' '
        # 4
        arg=arg+self.start_time.strftime('%H')+' '
        # 5
        arg=arg+self.end_time.strftime('%H')+' '
        # 6
        arg=arg+self.wps_root+' ' 
        # 7
        arg=arg+self.wrf_root+' '
        # 8
        if self.run_real:
            arg=arg+'1 ' 
        else:
            arg=arg+'0 ' 
        # 9
        if self.run_wrf:
            arg=arg+'1 ' 
        else:
            arg=arg+'0 '
        # 10
        arg=arg+self.ntask+' '

        if self.nml_rewrite:
            nml_tmp='./db/nml_temp/'+self.nml_temp
            nml_tmp=nml_tmp+'/namelist.input.'+self.drv_type
            os.system('cp '+nml_tmp+' '+self.wrf_root+'/namelist.input')
        
        os.system('sh ./drv_sh/auto_wrf.sh '+arg)

    def ctrl_archive(self):
        """ archive wrfout """
        # 1
        arg=self.start_time.strftime('%Y%m%d%H')+' '
        # 2
        arg=arg+self.wrf_root+' '
        # 3
        arg=arg+self.archroot
        
        os.system('sh ./drv_sh/archive_wrfout.sh '+arg)
 
