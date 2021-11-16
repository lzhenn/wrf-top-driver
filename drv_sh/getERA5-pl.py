import cdsapi
import datetime

for i in range(2020,2021):
    int_time_obj = datetime.datetime.strptime(str(i)+'0101', '%Y%m%d')
    end_time_obj = datetime.datetime.strptime(str(i)+'0101', '%Y%m%d')
    file_time_delta=datetime.timedelta(days=1)
    curr_time_obj = int_time_obj

    c = cdsapi.Client()

    #
    # !!!Area: North/West/South/East!!!
    #

    while curr_time_obj <= end_time_obj:
        c.retrieve(
            'reanalysis-era5-pressure-levels',
            {
                'product_type':'reanalysis',
                'format':'grib',
                'pressure_level':[
                    '50','70',
                    '100','150',
                    '200','250',
                    '300','350',
                    '400','450',
                    '500','550','600',
                    '650','700','750',
                    '775','800','825',
                    '850','875','900',
                    '925','950','975',
                    '1000'
                ],
                'date':curr_time_obj.strftime('%Y%m%d'),
                'area':'52/65/0/163',
                'time':'00/to/23/by/1',
                'variable':[
                    'geopotential','relative_humidity','specific_humidity',
                    'temperature','u_component_of_wind','v_component_of_wind'
                ]
            },
            curr_time_obj.strftime('%Y%m%d')+'-pl.grib')
        curr_time_obj=curr_time_obj+file_time_delta
