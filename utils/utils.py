#/usr/bin/env python
"""Commonly used utilities

    Function    
    ---------------
   
    throw_error(msg):
        Throw error with call source and error message

"""
import logging

def throw_error(msg):
    '''
    throw error and exit
    '''
    logging.error(msg)
    exit()

def write_log(msg, lvl=20):
    '''
    write logging log to log file
    level code:
        CRITICAL    50
        ERROR   40
        WARNING 30
        INFO    20
        DEBUG   10
        NOTSET  0
    '''

    logging.log(lvl, msg)


def parse_fmt_timepath(tgt_time, fmtpath):
    '''
    parse time string to datetime object
    '''
    seg_path=fmtpath.split('@')
    parsed_path=''
    for seg in seg_path:
        if seg.startswith('%'):
            parsed_path+=tgt_time.strftime(seg)
        else:
            parsed_path+=seg
    return parsed_path


def get_glb_const():
    ''' return global long const dict '''
    cdic={
            'ERA5_SL_VARS':[
                        '10m_u_component_of_wind','10m_v_component_of_wind','2m_dewpoint_temperature',
                        '2m_temperature','land_sea_mask','mean_sea_level_pressure',
                        'sea_ice_cover','sea_surface_temperature','skin_temperature',
                        'snow_depth','soil_temperature_level_1','soil_temperature_level_2',
                        'soil_temperature_level_3','soil_temperature_level_4','surface_pressure',
                        'volumetric_soil_water_layer_1','volumetric_soil_water_layer_2','volumetric_soil_water_layer_3',
                        'volumetric_soil_water_layer_4'],
            'ERA5_PL_LAYS':[
                        '50','70','100','150','200','250',
                        '300','350','400','450','500','550','600',
                        '650','700','750','775','800','825',
                        '850','875','900','925','950','975','1000'],
            'ERA5_PL_VARS':[
                        'geopotential','relative_humidity','specific_humidity',
                        'temperature','u_component_of_wind','v_component_of_wind'],
            }

    return cdic
