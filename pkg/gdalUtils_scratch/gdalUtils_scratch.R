
### gdal_rasterize

dst_filename_original  <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
# Back up the file, since we are going to burn stuff into it.
dst_filename <- paste(tempfile(),".tif",sep="")
file.copy(dst_filename_original,dst_filename,overwrite=TRUE)

# Before plot:
plotRGB(brick(dst_filename))

src_dataset <- system.file("external/tahoe_highrez_training.shp", package="gdalUtils")

# gdal_rasterize -b 1 -b 2 -b 3 -burn 255 -burn 0 -burn 0 -l tahoe_highrez_training tahoe_highrez_training.shp tempfile.tif
tahoe_burned <- gdal_rasterize(src_dataset,dst_filename,
	b=c(1,2,3),burn=c(0,255,0),l="tahoe_highrez_training",verbose=TRUE,output_Raster=TRUE)

plotRGB(brick(dst_filename))

#### gdaldem
input_dem  <- system.file("external/tahoe_lidar_highesthit.tif", package="gdalUtils")
plot(raster(input_dem),col=gray.colors(256))

# Hillshading:
# Command-line gdaldem call:
# gdaldem hillshade tahoe_lidar_highesthit.tif output_hillshade.tif
output_hillshade <- gdaldem(mode="hillshade",input_dem=input_dem,output="output_hillshade.tif",output_Raster=TRUE)
plot(output_hillshade,col=gray.colors(256))

# Slope:
# Command-line gdaldem call:
# gdaldem slope tahoe_lidar_highesthit.tif output_slope.tif -p
output_slope <- gdaldem(mode="slope",input_dem=input_dem,output="output_slope.tif",p=TRUE,output_Raster=TRUE)
plot(output_slope,col=gray.colors(256))

# Aspect:
# Command-line gdaldem call:
# gdaldem aspect tahoe_lidar_highesthit.tif output_aspect.tif
output_aspect <- gdaldem(mode="aspect",input_dem=input_dem,output="output_aspect.tif",output_Raster=TRUE)
plot(output_aspect,col=gray.colors(256))


### ogrinfo
datasource_name <- system.file("external/tahoe_highrez_training.shp", package="gdalUtils")

### batch_gdal_translate
input_folder <- system.file("external",package="gdalUtils")
list.files(input_folder,pattern=".tif")
output_folder <- tempdir()
# sfQuickInit() # from package spatial.tools to launch a parallel PSOCK cluster
batch_gdal_translate(infiles=input_folder,outdir=output_folder,outsuffix="_converted.envi",of="ENVI",pattern=".tif$")
list.files(output_folder,pattern="_converted.envi$")
# sfQuickStop() # from package spatial.tools to stop a parallel PSOCK cluster

### gdalbuildvrt
layer1 <- system.file("external/tahoe_lidar_bareearth.tif", package="gdalUtils")
layer2 <- system.file("external/tahoe_lidar_highesthit.tif", package="gdalUtils")
output.vrt <- paste(tempfile(),".vrt",sep="")
gdalbuildvrt(gdalfile=c(layer1,layer2),output.vrt=output.vrt,separate=TRUE)
gdalinfo(output.vrt)

### mosaic rasters
layer1 <- system.file("external/tahoe_lidar_bareearth.tif", package="gdalUtils")
layer2 <- system.file("external/tahoe_lidar_highesthit.tif", package="gdalUtils")
mosaic_rasters(gdalfile=c(layer1,layer2),dst_dataset="test_mosaic.envi",separate=TRUE,of="ENVI",
		verbose=TRUE,output_Raster=TRUE)


### gdaladdo
filename  <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
temp_filename <- paste(tempfile(),".tif",sep="")
file.copy(from=filename,to=temp_filename,overwrite=TRUE)
gdalinfo(filename)
gdaladdo(r="average",temp_filename,levels=c(2,4,8,16),verbose=TRUE)
gdalinfo(temp_filename)


### ogr2ogr
src_datasource_name <- system.file("external/tahoe_highrez_training.shp", package="gdalUtils")
dst_datasource_name <- paste(tempfile(),".shp",sep="")
ogrInfo(src_datasource_name,"tahoe_highrez_training")
# reproject the input to mercator
ogr2ogr(src_datasource_name,dst_datasource_name,t_srs="EPSG:3395",verbose=TRUE)
ogrInfo(dirname(dst_datasource_name),layer=remove_file_extension(basename(dst_datasource_name)))

### gdal_contour
 gdal_setInstallation()
 valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
 if(require(raster) && require(rgdal) && valid_install)
 {
 # Example from the original gdal_contour documentation:
 # 	gdal_contour -a elev dem.tif contour.shp -i 10.0 
 input_dem  <- system.file("external/tahoe_lidar_bareearth.tif", package="gdalUtils")
 output_shapefile <- paste(tempfile(),".shp",sep="")
 contour_output <- gdal_contour(src_filename=input_dem,dst_filename=output_shapefile,
		 a="Elevation",i=5.,output_Vector=TRUE) 

 
 # Back up the file, since we are going to burn stuff into it.
 dst_filename <- paste(tempfile(),".tif",sep="")
 file.copy(dst_filename_original,dst_filename,overwrite=TRUE)
 #Before plot:
 plotRGB(brick(dst_filename))
 src_dataset <- system.file("external/tahoe_highrez_training.shp", package="gdalUtils")
 tahoe_burned <- gdal_rasterize(src_dataset,dst_filename,
 	b=c(1,2,3),burn=c(0,255,0),l="tahoe_highrez_training",verbose=TRUE,output_Raster=TRUE)
 #After plot:
 plotRGB(brick(dst_filename))
 }
