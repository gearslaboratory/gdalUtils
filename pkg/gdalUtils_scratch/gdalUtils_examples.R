library(gdalUtils)

### gdal_rasterize
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(raster) && require(rgdal) && valid_install)
{
# Example from the original gdal_rasterize documentation:
# gdal_rasterize -b 1 -b 2 -b 3 -burn 255 -burn 0
# 	-burn 0 -l tahoe_highrez_training tahoe_highrez_training.shp tempfile.tif
	dst_filename_original  <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
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

### gdal_translate
# We'll pre-check to make sure there is a valid GDAL install
# and that raster and rgdal are also installed.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(raster) && require(rgdal) && valid_install)
{
# Example from the original gdal_translate documentation:
	src_dataset <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
# Original gdal_translate call:
# gdal_translate -of GTiff -co "TILED=YES" tahoe_highrez.tif tahoe_highrez_tiled.tif
	gdal_translate(src_dataset,"tahoe_highrez_tiled.tif",of="GTiff",co="TILED=YES",verbose=TRUE)
# Pull out a chunk and return as a raster:
	gdal_translate(src_dataset,"tahoe_highrez_tiled.tif",of="GTiff",
			srcwin=c(1,1,100,100),output_Raster=TRUE,verbose=TRUE)
# Notice this is the equivalent, but follows gdal_translate's parameter format:
	gdal_translate(src_dataset,"tahoe_highrez_tiled.tif",of="GTiff",
			srcwin="1 1 100 100",output_Raster=TRUE,verbose=TRUE)
}


### gdaladdo
# We'll pre-check to make sure there is a valid GDAL install.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(valid_install)
{
	filename  <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
	temp_filename <- paste(tempfile(),".tif",sep="")
	file.copy(from=filename,to=temp_filename,overwrite=TRUE)
	gdalinfo(filename)
	gdaladdo(r="average",temp_filename,levels=c(2,4,8,16),verbose=TRUE)
	gdalinfo(temp_filename)
}


### gdalbuildvrt
?gdalbuildvrt

# We'll pre-check to make sure there is a valid GDAL install.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(valid_install)
{
	layer1 <- system.file("external/tahoe_lidar_bareearth.tif", package="gdalUtils")
	layer2 <- system.file("external/tahoe_lidar_highesthit.tif", package="gdalUtils")
	output.vrt <- paste(tempfile(),".vrt",sep="")
	gdalbuildvrt(gdalfile=c(layer1,layer2),output.vrt=output.vrt,separate=TRUE,verbose=TRUE)
	gdalinfo(output.vrt)
}

### gdaldem
?gdaldem

# We'll pre-check to make sure there is a valid GDAL install
# and that raster and rgdal are also installed.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(raster) && require(rgdal) && valid_install)
{
# We'll pre-check for a proper GDAL installation before running these examples:
	gdal_setInstallation()
	if(!is.null(getOption("gdalUtils_gdalPath")))
	{
		input_dem  <- system.file("external/tahoe_lidar_highesthit.tif", package="gdalUtils")
		plot(raster(input_dem),col=gray.colors(256))
		
# Hillshading:
# Command-line gdaldem call:
# gdaldem hillshade tahoe_lidar_highesthit.tif output_hillshade.tif
		output_hillshade <- gdaldem(mode="hillshade",input_dem=input_dem,
				output="output_hillshade.tif",output_Raster=TRUE,verbose=TRUE)
		plot(output_hillshade,col=gray.colors(256))
		
# Slope:
# Command-line gdaldem call:
# gdaldem slope tahoe_lidar_highesthit.tif output_slope.tif -p
		output_slope <- gdaldem(mode="slope",input_dem=input_dem,
				output="output_slope.tif",p=TRUE,output_Raster=TRUE,verbose=TRUE)
		plot(output_slope,col=gray.colors(256))
		
# Aspect:
# Command-line gdaldem call:
# gdaldem aspect tahoe_lidar_highesthit.tif output_aspect.tif
		output_aspect <- gdaldem(mode="aspect",input_dem=input_dem,
				output="output_aspect.tif",output_Raster=TRUE,verbose=TRUE)
		plot(output_aspect,col=gray.colors(256))
	}
}


### gdalinfo
?gdalinfo

# We'll pre-check to make sure there is a valid GDAL install.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(valid_install)
{
	src_dataset <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
# Command-line gdalinfo call:
# gdalinfo tahoe_highrez.tif
	gdalinfo(src_dataset,verbose=TRUE)
}

### gdalsrsinfo
?gdalsrsinfo

# We'll pre-check to make sure there is a valid GDAL install.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(valid_install)
{
	src_dataset <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
# Command-line gdalsrsinfo call:
# gdalsrsinfo -o proj4 tahoe_highrez.tif
	gdalsrsinfo(src_dataset,o="proj4",verbose=TRUE)
# Export as CRS:
	gdalsrsinfo(src_dataset,as.CRS=TRUE,verbose=TRUE)
}

### gdalwarp
?gdalwarp

# We'll pre-check to make sure there is a valid GDAL install
# and that raster and rgdal are also installed.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(raster) && require(rgdal) && valid_install)
{
# Example from the original gdal_translate documentation:
	src_dataset <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
# Command-line gdalwarp call:
# gdalwarp -t_srs '+proj=utm +zone=11 +datum=WGS84' raw_spot.tif utm11.tif
	gdalwarp(src_dataset,dstfile="tahoe_highrez_utm11.tif",
			t_srs='+proj=utm +zone=11 +datum=WGS84',output_Raster=TRUE,
			verbose=TRUE,overwrite=TRUE)
}

### ogr2ogr
?ogr2ogr

# We'll pre-check to make sure there is a valid GDAL install.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(valid_install)
{
	src_datasource_name <- system.file("external/tahoe_highrez_training.shp", package="gdalUtils")
	dst_datasource_name <- paste(tempfile(),".shp",sep="")
	ogrinfo(src_datasource_name,"tahoe_highrez_training",verbose=TRUE)
# reproject the input to mercator
	ogr2ogr(src_datasource_name,dst_datasource_name,t_srs="EPSG:3395",verbose=TRUE)
	ogrinfo(dirname(dst_datasource_name),layer=remove_file_extension(basename(dst_datasource_name)),verbose=TRUE)
}

### ogrinfo
?ogrinfo

gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(valid_install)
{
	datasource_name <- system.file("external/tahoe_highrez_training.shp", package="gdalUtils")
# Display all available formats:
# Command-line ogrinfo call:
# ogrinfo --formats
	ogrinfo(formats=TRUE,verbose=TRUE)
	
# Get info on an entire shapefile:
# ogrinfo tahoe_highrez_training.shp
	ogrinfo(datasource_name,verbose=TRUE)
	
# Get info on the layer of the shapefile:
# ogrinfo tahoe_highrez_training.shp tahoe_highrez_training
	ogrinfo(datasource_name,"tahoe_highrez_training",verbose=TRUE)
}


### gdal_contour
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
# We'll pre-check for a proper GDAL installation before running the examples:
if(valid_install && require(rgdal))
{
	input_dem  <- system.file("external/tahoe_lidar_highesthit.tif", package="gdalUtils")
	plot(raster(input_dem),col=gray.colors(256))
	output_contours <- gdal_contour(src_filename=input_dem,dst_filename="contour.shp",a="elev",i=10.0,output_Vector=TRUE)
	plot(output_contours)
}





#### gdaltindex
# We'll pre-check to make sure there is a valid GDAL install
# and that raster and rgdal are also installed.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(rgdal) && valid_install)
{
# Modified example from the original gdaltindex documentation:
src_folder <- system.file("external/", package="gdalUtils")
output_shapefile <- paste(tempfile(),".shp",sep="")
# Command-line gdalwarp call:
# gdaltindex doq_index.shp external/*.tif
gdaltindex(output_shapefile,list.files(path=src_folder,pattern=glob2rx("*.tif"),full.names=TRUE),
output_Vector=TRUE,verbose=TRUE)
}




#### gdal_grid
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(raster) && valid_install)
{
	# Create a properly formatted CSV:
	temporary_dir <- tempdir()
	tempfname_base <- file.path(temporary_dir,"dem")
	tempfname_csv <- paste(tempfname_base,".csv",sep="")
	
	pts <- data.frame(
			Easting=c(86943.4,87124.3,86962.4,87077.6),
			Northing=c(891957,892075,892321,891995),
			Elevation=c(139.13,135.01,182.04,135.01)
		)
			
	write.csv(pts,file=tempfname_csv,row.names=FALSE)
	
	# Now make a matching VRT file
	tempfname_vrt <- paste(tempfname_base,".vrt",sep="")
	vrt_header <- c(
			'<OGRVRTDataSource>',
					'\t<OGRVRTLayer name="dem">',
					'\t<SrcDataSource>dem.csv</SrcDataSource>',
					'\t<GeometryType>wkbPoint</GeometryType>', 
					'\t<GeometryField encoding="PointFromColumns" x="Easting" y="Northing" z="Elevation"/>',
					'\t</OGRVRTLayer>',
					'\t</OGRVRTDataSource>'			
			)
	vrt_filecon <- file(tempfname_vrt,"w")
	writeLines(vrt_header,con=vrt_filecon)
	close(vrt_filecon)
	
	# Now run gdal_grid:
	tempfname_tif <- paste(tempfname_base,".tiff",sep="")
	
	setMinMax(gdal_grid(src_datasource=tempfname_vrt,
			dst_filename=tempfname_tif,a="invdist:power=2.0:smoothing=1.0",
			txe=c(85000,89000),tye=c(894000,890000),outsize=c(400,400),of="GTiff",ot="Float64",
			l="dem",output_Raster=TRUE))
}


#### gdallocationinfo
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(valid_install)
{
	src_dataset <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
	# Raw output of a single coordinate:
	gdallocationinfo(srcfile=src_dataset,x=10,y=10)

	# A matrix of coordinates and a clean, matrix output:
	coords <- rbind(c(10,10),c(20,20),c(30,30))
	gdallocationinfo(srcfile=src_dataset,coords=coords,valonly=TRUE,raw_output=FALSE)
	
	
}


#### gdalmanage:
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(valid_install)
{
	# Using identify mode
	# Report the data format of the raster file by using the identify mode and specifying a data file name:
	src_dataset <- system.file("external/tahoe_highrez.tif", package="gdalUtils")
	gdalmanage(mode="identify",datasetname=src_dataset)
	
	# Recursive mode will scan subfolders and report the data format:	
	src_dir <- system.file("external/", package="gdalUtils")
	gdalmanage(mode="identify",datasetname=src_dir,r=TRUE)
	
	\dontrun{
	# Using copy mode	
	# Copy the raster data:
	file_copy <- tempfile(fileext=".tif")
	gdalmanage(mode="copy",src_dataset,file_copy)	
	file.exists(file_copy)
	
	# Using rename mode
	# Rename the raster data:
	new_name <- tempfile(fileext=".tif")
	gdalmanage(mode="rename",file_copy,new_name)	
	file.exists(new_name)
	
	# Using delete mode
	# Delete the raster data:
	gdalmanage(mode="delete",new_name)	
	file.exists(new_name)
	
	}
}

#### ogrtindex
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(rgdal) && valid_install)
{
	tempindex <- tempfile(fileext=".shp")
	src_dir <- system.file("external/", package="gdalUtils")
	src_files <- list.files(src_dir,pattern=".shp",full.names=TRUE)
	ogrtindex(output_dataset=tempindex,src_dataset=src_files,
			accept_different_schemas=TRUE,output_Vector=TRUE)
}




#### mosaic_rasters
# We'll pre-check to make sure there is a valid GDAL install
# and that raster and rgdal are also installed.
# Note this isn't strictly neccessary, as executing the function will
# force a search for a valid GDAL install.
gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(raster) && require(rgdal) && valid_install)
{
	layer1 <- system.file("external/tahoe_lidar_bareearth.tif", package="gdalUtils")
	layer2 <- system.file("external/tahoe_lidar_highesthit.tif", package="gdalUtils")
	mosaic_rasters(gdalfile=c(layer1,layer2),dst_dataset="test_mosaic.envi",separate=TRUE,of="ENVI",
			verbose=TRUE)
	gdalinfo("test_mosaic.envi")
}