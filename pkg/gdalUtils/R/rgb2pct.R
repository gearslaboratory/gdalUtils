#' rgb2pct
#' 
#' R wrapper for rgb2pct.py: Convert a 24bit RGB image to 8bit paletted.
#' 
#' @param source_file Character. The input RGB file.
#' @param dest_file Character. The output pseudo-colored file that will be created.
#' @param n Numeric. Select the number of colors in the generated color table. Defaults to 256. Must be between 2 and 256.
#' @param pct Character. Extract the color table from palette_file instead of computing it. Can be used to have a consistent color table for multiple files. The palette_file must be a raster file in a GDAL supported format with a palette.
#' @param of Character. Select the output format. Starting with GDAL 2.3, if not specified, the format is guessed from the extension (previously was GTiff). Use the short format name. Only output formats supporting pseudo-color tables should be used.
#' @param output_Raster Logical. Return output dst_dataset as a RasterBrick?
#' @param config Character. Sets runtime configuration options for GDAL.  See https://trac.osgeo.org/gdal/wiki/ConfigOptions for more information.
#' @param ignore.full_scan Logical. If FALSE, perform a brute-force scan if other installs are not found.  Default is TRUE.
#' @param verbose Logical. Enable verbose execution? Default is FALSE.  

#' @return NULL or if(output_Raster), a RasterBrick.
#' @author Jonathan A. Greenberg (\email{gdalUtils@@estarcion.net}) (wrapper) and Frank Warmerdam (GDAL lead developer).
#' @details This is an R wrapper for the 'rgb2pct.py' function that is part of the 
#' Geospatial Data Abstraction Library (GDAL).  It follows the parameter naming
#' conventions of the original function, with some modifications to allow for more R-like
#' parameters.  For all parameters, the user can use a single character string following,
#' precisely, the gdal_contour format (\url{http://www.gdal.org/rgb2pct.html}), or,
#' in some cases, can use R vectors to achieve the same end.  
#' 
#' This function assumes the user has a working GDAL and python on their system.  If the 
#' "gdalUtils_gdalPath" option has been set (usually by gdal_setInstallation),
#' the GDAL found in that path will be used.  If nothing is found, gdal_setInstallation
#' will be executed to attempt to find a working GDAL that has the right drivers 
#' as specified with the "of" (output format) parameter.
#' 
#' The user can choose to (optionally) return a RasterBrick of the output file (assuming
#' raster/rgdal supports the particular output format).
#'
#' @references \url{http://www.gdal.org/rgb2pct.html}
#' @examples 
#' # We'll pre-check to make sure there is a valid GDAL install
#' # and that raster and rgdal are also installed.
#' # Note this isn't strictly neccessary, as executing the function will
#' # force a search for a valid GDAL install.
#' gdal_setInstallation()
#' valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
#' if(require(raster) && require(rgdal) && valid_install)
#' {
#' # Example from the original gdal_contour documentation:
#' # 	gdal_contour -a elev dem.tif contour.shp -i 10.0 
#' # Choose a DEM:
#' input_dem  <- system.file("external/tahoe_lidar_bareearth.tif", package="gdalUtils")
#' # Setup an output filename (shapefile):
#' output_shapefile <- paste(tempfile(),".shp",sep="")
#' contour_output <- gdal_contour(src_filename=input_dem,dst_filename=output_shapefile,
#' 		a="Elevation",i=5.,output_Vector=TRUE)
#' # Plot the contours using spplot:
#' spplot(contour_output["Elevation"],contour=TRUE)
#' }
#' @import rgdal reticulate
#' @export

rgb2pct <- function(
		source_file,dest_file,
		n,pct,of,
		output_Raster=FALSE,
		ignore.full_scan=TRUE,
		verbose=FALSE)
{
	if(output_Raster && (!requireNamespace("raster") || !requireNamespace("rgdal")))
	{
		warning("rgdal and/or raster not installed. Please install.packages(c('rgdal','raster')) or set output_Raster=FALSE")
		return(NULL)
	}
	
	parameter_values <- as.list(environment())
	
	if(verbose) message("Checking gdal_installation...")
	gdal_setInstallation(ignore.full_scan=ignore.full_scan)
	if(is.null(getOption("gdalUtils_gdalPath"))) return()
	
	if(verbose) message("Checking python installation...")
	py_check <- py_available(initialize=T)
	if(!py_check) stop("Python not available, please fix.")
	
	# Place all gdal function variables into these groupings:
	parameter_variables <- list(
			logical = list(
					varnames <- c(
							
					)),
			vector = list(
					varnames <- c("n"
					
					)),
			scalar = list(
					varnames <- c(
							
					)),
			character = list(
					varnames <- c(
							"source_file","dest_file",
							"pct","of"	
					)),
			repeatable = list(
					varnames <- c(
							
					))
	)
	
	parameter_order <- c(
			"n","pct","of","source_file","dest_file"
	)
	
	parameter_noflags <- c("source_file","dest_file")
	
	parameter_noquotes <- unlist(parameter_variables$vector)
	
	parameter_doubledash <- c()
	
	executable <- "rgb2pct.py"
	
	cmd <- gdal_cmd_builder(
			executable=executable,
			parameter_variables=parameter_variables,
			parameter_values=parameter_values,
			parameter_order=parameter_order,
			parameter_noflags=parameter_noflags,
			parameter_noquotes=parameter_noquotes,
			parameter_doubledash=parameter_doubledash,
			#		gdal_installation_id=gdal_chooseInstallation(hasDrivers=of))
			gdal_installation_id=gdal_chooseInstallation(),
			python_util=TRUE)
	
	if(verbose) message(paste("GDAL command being used:",cmd))
	
	cmd_output <- system(cmd,intern=TRUE) 
	
	if(output_Raster)
	{
		return(brick(dest_file))	
	} else
	{
		return(NULL)
	}		
}