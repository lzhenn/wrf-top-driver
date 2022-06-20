#!/usr/bin/env python3

import os

# set GEO_PATH below to link the geo_em data
GEO_PATH='/home/lzhenn/array74/data/geo_em'

os.system('ln -sf '+GEO_PATH+'/* ./db/geo_em/')
