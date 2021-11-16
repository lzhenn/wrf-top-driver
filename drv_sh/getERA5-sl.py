import cdsapi
import datetime
for i in range(2020,2021):
    int_time_obj = datetime.datetime.strptime(str(i)+'0101', '%Y%m%d')
    end_time_obj = datetime.datetime.strptime(str(i)+'0101', '%Y%m%d')
    file_time_delta=datetime.timedelta(days=1)
    curr_time_obj = int_time_obj
    c = cdsapi.Client()

    # Area: North/West/South/East

    while curr_time_obj <= end_time_obj:
        c.retrieve(
            'reanalysis-era5-single-levels',
            {
                'product_type':'reanalysis',
                'format':'grib',
                'variable':[
                    '10m_u_component_of_wind','10m_v_component_of_wind','2m_dewpoint_temperature',
                    '2m_temperature','land_sea_mask','mean_sea_level_pressure',
                    'sea_ice_cover','sea_surface_temperature','skin_temperature',
                    'snow_depth','soil_temperature_level_1','soil_temperature_level_2',
                    'soil_temperature_level_3','soil_temperature_level_4','surface_pressure',
                    'volumetric_soil_water_layer_1','volumetric_soil_water_layer_2','volumetric_soil_water_layer_3',
                    'volumetric_soil_water_layer_4'
                ],
                'date':curr_time_obj.strftime('%Y%m%d'),
                'area':'52/65/0/163',
                'time':'00/to/23/by/1',
            },
            curr_time_obj.strftime('%Y%m%d')+'-sl.grib')
        curr_time_obj=curr_time_obj+file_time_delta
