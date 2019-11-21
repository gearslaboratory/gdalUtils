# TODO: Add comment
# 
# Author: jgreenberg
###############################################################################



require(gdalUtils)
setwd("C:\\Users\\jgreenberg\\Downloads")
files <- list.files(pattern = ".hdf$")

get_subdatasets(files,names_only=TRUE)
# get_subdatasets(src_dataset,names_only=TRUE)[sd_index]

hestir_out <- gdal_translate(src_dataset = files[1], dst_dataset = "modis2.tif", of="GTiff", sd_index = 2, verbose =TRUE,output_Raster=T)
r1 = raster("modis1.tif")
