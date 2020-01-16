#' Mosaic raster files using GDAL Utilities
#' 
#' @param gdalfile Character. Input files (as a character vector) or a wildcard search term (e.g. "*.tif") 
#' @param dst_dataset Character. The destination file name.
#' @param output.vrt Character. Output VRT file.  If NULL a temporary .vrt file will be created.
#' @param output_Raster Logical. Return output dst_dataset as a RasterBrick?
#' @param separate Logical. (starting with GDAL 1.7.0) Place each input file into a separate stacked band.  Unlike gdalbuildvrt, the full stack is placed in the mosaic, not just the first band.
#' @param trim_margins Numeric. Pre-crop the input tiles by a fixed number of pixels before mosaicking.  Can be a single value or four values representing the left, top, right, and bottom margins, respectively.
#' @param gdalwarp_index Numeric. If gdalwarp_index is numeric, the value is used as the index of the gdalfile to match projections and resolutions against when file projections don't match.  The default = 1 (the first input file).
#' @param gdalwarp_params List.  Set gdalwarp parameters if input file projections don't match.  t_srs and tr set here will override those chosen by gdalwarp_index.  In general, the only thing you would set here is the resampling algorithm, which defaults to nearest neighbor ("near").
#' @param force_ot Character. ("Byte"/"Int16"/"UInt16"/"UInt32"/"Int32"/"Float32"/"Float64"/"CInt16"/"CInt32"/"CFloat32"/"CFloat64") Forces all bands to be the same datatype. This is helpful if you are using input files of different data types and output formats (e.g. GTiff) that don't support mixed datatypes.
#' @param verbose Logical. Enable verbose execution? Default is FALSE.  
#' @param ... Parameters to pass to \code{\link{gdalbuildvrt}} or \code{\link{gdal_translate}}.
#' 
#' @details This function mosaics a set of input rasters (gdalfile) using parameters
#' found in \code{\link{gdalbuildvrt}} and subsequently exports the mosaic to 
#' an output file (dst_dataset) using parameters found in \code{\link{gdal_translate}}.  The user
#' can choose to preserve the intermediate output.vrt file, but in general this is not
#' needed.
#' @return Either a list of NULLs or a list of RasterBricks depending on whether output_Raster is set to TRUE.
#' @author Jonathan A. Greenberg (\email{gdalUtils@@estarcion.net})
#' @seealso \code{\link{gdalbuildvrt}}, \code{\link{gdal_translate}}
#' @examples 
#' # We'll pre-check to make sure there is a valid GDAL install
#' # and that raster and rgdal are also installed.
#' # Note this isn't strictly neccessary, as executing the function will
#' # force a search for a valid GDAL install.
#' outdir <- tempdir()
#' gdal_setInstallation()
#' valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
#' if(require(raster) && require(rgdal) && valid_install)
#' {
#' layer1 <- system.file("external/tahoe_lidar_bareearth.tif", package="gdalUtils")
#' layer2 <- system.file("external/tahoe_lidar_highesthit.tif", package="gdalUtils")
#' mosaic_rasters(gdalfile=c(layer1,layer2),dst_dataset=file.path(outdir,"test_mosaic.envi"),
#' 		separate=TRUE,of="ENVI",verbose=TRUE)
#' gdalinfo("test_mosaic.envi")
#' }
#' @import rgdal
#' @importFrom utils write.table
#' @export

mosaic_rasters <- function(gdalfile,dst_dataset,output.vrt=NULL,output_Raster=FALSE,
		separate=FALSE,
		trim_margins = NULL,
		gdalwarp_index=1,
		gdalwarp_params=list(r="near"),
		force_ot=NULL,
		verbose=FALSE,
		...)
{
	# CRAN check to fix foreach variable errors:
	k <- NULL
	b <- NULL
	
	# Check to make sure all the input files exist on the system:
	if(verbose) message("Checking to make sure all the input files exist...")
	files_exist <- sapply(gdalfile,file.exists)
	if(!all(files_exist))
	{
		missing_files <- gdalfile[!files_exist]
		stop(paste("Some of the input files are missing:",missing_files))
	}
	
	if(output_Raster && (!requireNamespace("raster") || !requireNamespace("rgdal")))
	{
		warning("rgdal and/or raster not installed. Please install.packages(c('rgdal','raster')) or set output_Raster=FALSE")
		return(NULL)
	}
	
	if(verbose) message("Checking gdal_installation...")
	gdal_setInstallation()
	if(is.null(getOption("gdalUtils_gdalPath"))) return()
	
	# Need to check for projection differences before mosaicking...
	# This is probably not worth doing in parallel:
	gdalfile_proj4s <- foreach(k=gdalfile,.packages="gdalUtils",.combine="c") %do%
			{
				return(gdalsrsinfo(k,o="proj4"))	
			}
	
	# We need to clean up the text?
	# http://stackoverflow.com/questions/2261079/how-to-trim-leading-and-trailing-whitespace-in-r
	trim.trailing <- function (x) sub("\\s+$", "", x)
	gdalfile_proj4s <- trim.trailing(gsub("'","",gdalfile_proj4s))
	
	# browser()
	
	if(is.numeric(gdalwarp_index) && (is.null(gdalwarp_params$t_srs) || is.na(gdalwarp_params$t_srs)))
	{
		gdalwarp_params$t_srs <- gdalfile_proj4s[gdalwarp_index]
		
		# Match the resolution also:
		temp_gdalfile_info <- gdalinfo(gdalfile[gdalwarp_index],raw_output=F)
		gdalwarp_params$tr <- abs(c(temp_gdalfile_info$res.x,temp_gdalfile_info$res.y))
	}
		
	if(!(all(gdalfile_proj4s==gdalfile_proj4s[1])))
	{
		if(verbose) message("Not all projections are identical...")
		if(is.null(gdalwarp_params$t_srs) || is.na(gdalwarp_params$t_srs)) 
		{
			stop("Please set a valid gdalwarp_params$t_srs or gdalwarp_index...")
		} else
		{
			# Make vrts for all files:
			gdalfile_vrts <- foreach(k=seq(gdalfile),.combine="c") %dopar%
					{
						temp_vrt_name <- paste(tempfile(),".vrt",sep="")
						gdalbuildvrt(gdalfile=gdalfile[k],
								output.vrt=temp_vrt_name,
								verbose=verbose)
						if(gdalfile_proj4s[k] != gdalwarp_params$t_srs)
						{
							temp_vrt_warped_name <- paste(tempfile(),"_warped.vrt",sep="")
							gdalwarp_params_temp <- gdalwarp_params
							gdalwarp_params_temp$srcfile <- gdalfile[k]
							gdalwarp_params_temp$dstfile <- temp_vrt_warped_name
							gdalwarp_params_temp$of <- "VRT" 		
							gdalwarp_params_temp$verbose = verbose
							do.call(gdalwarp,gdalwarp_params_temp)
							return(temp_vrt_warped_name)
						} else
						{
							return(temp_vrt_name)
						}
						
					}
			
		}
		gdalfile <- gdalfile_vrts	
	}
	
	
	if(is.null(output.vrt))
	{
		output.vrt <- paste(tempfile(),".vrt",sep="")
	}
	
	# Shrink 
	if(!is.null(trim_margins))
	{
		if(verbose) message("Trimming margins...")
		if(length(trim_margins)==1) 
		{
			trim_margins <- rep(trim_margins,4)
		}
		
		gdalfile_vrts <- foreach(k = seq(gdalfile),.combine="c") %dopar%
				{
					temp_gdalfile_info <- gdalinfo(gdalfile[k],raw_output=F)
					new_xmin <- temp_gdalfile_info$bbox[1,1] + trim_margins[1]*abs(temp_gdalfile_info$res.x)
					new_xmax <- temp_gdalfile_info$bbox[1,2] - trim_margins[3]*abs(temp_gdalfile_info$res.x)
					new_ymin <- temp_gdalfile_info$bbox[2,1] + trim_margins[2]*abs(temp_gdalfile_info$res.y)
					new_ymax <- temp_gdalfile_info$bbox[2,2] - trim_margins[4]*abs(temp_gdalfile_info$res.y)
					
					temp_vrt_name <- paste(tempfile(),".vrt",sep="")
					
					gdalbuildvrt(gdalfile=gdalfile[k],
							output.vrt=temp_vrt_name,te=c(new_xmin,new_ymin,new_xmax,new_ymax),
							verbose=verbose)
					
					return(temp_vrt_name)
				}
		gdalfile <- gdalfile_vrts
		
	}
	
	if(!is.null(force_ot))
	{
		if(verbose) message("Forcing output data type...")
		gdalfile_vrts <- foreach(k = seq(gdalfile),.combine="c") %dopar%
				{
					temp_vrt_name <- paste(tempfile(),".vrt",sep="")
					gdalbuildvrt(gdalfile=gdalfile[k],
							output.vrt=temp_vrt_name,
							verbose=verbose)
					temp_vrt_forcedot_name <- paste(tempfile(),"_forcedot.vrt",sep="")
					gdal_translate(src_dataset=temp_vrt_name,dst_dataset=temp_vrt_forcedot_name,ot=force_ot,of="VRT")
					return(temp_vrt_forcedot_name)
				}
		gdalfile <- gdalfile_vrts
	}
	
	# Finally, we need to fix the issue of there being multi-band files:
	if(separate)
	{
		# browser()
		if(verbose) message("Checking for multiband inputs...")
		gdalfile_vrts <- foreach(k=gdalfile,.packages="gdalUtils",.combine="c") %do%
				{
					nbands <- gdalinfo(k,raw_output=F)$bands
					if(nbands > 1)
					{
						gdalfile_singlebands <- foreach(b=seq(nbands),.packages="gdalUtils",.combine="c") %do%
								{
									temp_vrt_name <- paste(tempfile(),".vrt",sep="")
									gdalbuildvrt(gdalfile=k,b=b,
											output.vrt=temp_vrt_name,
											verbose=verbose)
									return(temp_vrt_name)
								}
						return(gdalfile_singlebands)
					} else
					{
						return(k)
					}
				}
		gdalfile <- gdalfile_vrts
	}
	
	# There is an error that occurs with a lot of files.  We are going to fix this by
	#	creating a file list.
	
	temp_file_list_name <- paste(tempfile(),".txt",sep="")
	print(gdalfile)
	write.table(gdalfile,temp_file_list_name,row.names=F,col.names=F,quote=F)
	
	# Now pass the right arguments to each function:
#browser()
#	additional_arguments <- list(...)
#	gdalbuildvrt_formals <- names(formals(gdalbuildvrt))
#	gdal_translate_formals <- names(formals(gdal_translate))
#	
#	gdalbuildvrt_additional_args <- additional_arguments[names(additional_arguments) %in% gdalbuildvrt_formals]
#	gdal_translate_additional_args <- additional_arguments[names(additional_arguments) %in% gdal_translate_formals]
#	
#	
	gdalbuildvrt(input_file_list=temp_file_list_name,separate=separate,output.vrt=output.vrt,verbose=verbose,...)
	outmosaic <- gdal_translate(src_dataset=output.vrt,dst_dataset=dst_dataset,
			output_Raster=output_Raster,verbose=verbose,...)
	return(outmosaic)
	
}