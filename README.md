# wrf-top-driver

ERA5-WRF-Driver is a dispatcher to arrange the WRF run using ERA5 data. 

### Usage

#### Data Downloading
Copy `getERA5-pl.py` and `getERA5-sl.py`to your ERA5 archive folder, and edit the two files properly to download the raw ERA5 data.
Please make sure you have configured **[ECMWF CDS API](https://cds.climate.copernicus.eu/api-how-to)** correctly, both in your shell environment and python interface.

#### Prepare geo_em files
When you deploy the ERA5-WRF-Driver, you may first run `geogrid.exe` in your `$WPS_DIR` to generate `geo_em.d0?.nc` files,
and then copy these files to `./db/geo_em/`, where is the source of geo_em files to dispatch from.

#### Prepare namelist template files
Namelist template files will be dispatched from `./db/nml_temp/$CASENAME`. For instance, 
`./db/nml_temp/path_hourly` is given as an example to use hourly ERA5 data to drive the WRF model, with hourly grid nudging turned on in domain1.
You may need to construct your own namelist files accordingly.

#### Modify conf/config.ini  file
Now you need to modify `conf/config.ini` to assign paths for WPS, WRF, source path of ERA5 data (with suffixes of pl and sl), and other options.
An example to run from 00Z Jan 1 to 00Z Jan 5, 2020 is shown below:

``` python
[INPUT]
wps_root=/home/metctm1/array_hq127/WPS_P1
wrf_root=/home/metctm1/array_hq127/WRFV3_P1/run
raw_root=/home/metctm1/array/data/era5/path-domain-hourly/

# namelist template case
nml_temp=path_hourly

[CORE]
run_wps= False 
run_real= True
run_wrf= True 
rewrite_geo_em=True
rewrite_namelist=True
model_strt_ts = 2020010100
model_end_ts  = 2020010500 
# number of tasks for running WRF
ntask=32

```

#### Run driver.py
Now in the root directory, let's use python3 to drive the pipeline:
``` sh
python3 serial_driver.py
```

#### Generate wrfout template
