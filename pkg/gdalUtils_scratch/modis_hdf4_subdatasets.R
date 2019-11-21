#' Return MODIS subdataset names
#'
#' @param x Character. A MODIS HDF4 filename.
#' @param verbose Logical. Enable verbose execution? Default is FALSE. 
#' @return A character vector of subdataset names.
#' @author Jonathan A. Greenberg
#' @examples \dontrun{ 
#'  # Download a MODIS GPP tile:
#'  download.file(
#' 		"http://e4ftl01.cr.usgs.gov/MOLT/MOD17A3.055/2000.01.01/
#' 		MOD17A3.A2000001.h19v10.055.2011276104211.hdf",
#' 		"MOD17A3.A2000001.h19v10.055.2011276104211.hdf",mode="wb")
#'  modis_hdf4_subdatasets("MOD17A3.A2000001.h19v10.055.2011276104211.hdf")
#' # This can be used in a Rgdal_translate statement by subselecting one layer:
#' gpp_sds <- modis_hdf4_subdatasets("MOD17A3.A2000001.h19v10.055.2011276104211.hdf")[1]
#' Rgdal_translate(gpp_sds,"MOD17A3.A2000001.h19v10.055.2011276104211.tif")
#' # This is an equivalent calling the index directly from Rgdal_translate:
#' Rgdal_translate("MOD17A3.A2000001.h19v10.055.2011276104211.hdf",
#' 		"MOD17A3.A2000001.h19v10.055.2011276104211.tif",modis_sds_index=1)
#' }
#' @export

modis_hdf4_subdatasets <- function(x,verbose=FALSE)
{
	
	if(dirname(x)==".")	{ x_fullpath <- file.path(getwd(),x) } else x_fullpath <- x
	if(!file.exists(normalizePath(x_fullpath))) { stop(paste(normalizePath(x_fullpath)," not found, exiting.",sep="")) }
	
	if(is.null(getOption("spatial.tools.gdalInstallation")))
	{
		if(verbose) { message("spatial.tools.gdalInstallation not set, searching for a valid GDAL install (this may take some time)...")}
		gdal_installation <- get_gdal_installation(required_drivers="HDF4")
	}
	
	if(is.null(getOption("spatial.tools.gdalInstallation")))
	{
		stop("GDAL with the proper drivers was not found, please check your installation.  See ?get_gdal_installation for more hints.")	
	}
	
	gdal_path <- getOption("spatial.tools.gdalInstallation")$gdal_path
	
	gdalinfo_path <- normalizePath(file.path(gdal_path,list.files(path=gdal_path,pattern=glob2rx("gdalinfo*"))[1]))
	
	cmd <- paste('"',gdalinfo_path,'" ','"',x_fullpath,'"',sep="")
	if(verbose) { message(paste("Using command: ",cmd,sep=""))}
	if (.Platform$OS=="unix")
	{    
		gdalinfo_dump <- system(cmd,intern=TRUE)
	} else
	{
		gdalinfo_dump <- shell(cmd,intern=TRUE)
	}
	
	subdataset_rawnames <- gdalinfo_dump[grep(glob2rx("*SUBDATASET*NAME*"),gdalinfo_dump)]
	
	subdataset_names <- sapply(X=seq(length(subdataset_rawnames)),FUN=function(X)
			{
				split1 <- strsplit(subdataset_rawnames[X],"=")
				return(gsub("\"","",split1[[1]][2]))
				
			})
	
	return(subdataset_names)
}