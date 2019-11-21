# interface to raster package

# slightly adapted from raster:::rasterTmpFile() 
gdalTmpFile <- function(prefix='raster_tmp_', driver="GTiff", verbose=FALSE)  
{
  require(raster)
  extension <- gdal_getExtension(driver)
  
  if(is.na(extension)| extension=="")
  {
    extension <- ".tif"
    if (verbose)
    {
      cat("Could not find extension for: ",driver, " using '.tif'") 
    }
  }
  
  d <- raster:::.tmpdir()
  
  while(TRUE)
  {
    f    <- paste(gsub(' ', '_', gsub(':', '', as.character(Sys.time()))), '_', paste(round(runif(5)*10), collapse=""), sep='')
    tmpf <- paste(d, prefix, f, extension, sep="")
    if (!file.exists(tmpf)) break
  }
  if (verbose)
  {
    cat('Writing raster to:', tmpf)
  }
  return(tmpf)
}

# bring any raster* object to a file supported by gdal, and give out the filename
gdal_rasterToGdal <- function(x, verbose=TRUE)
{
  require(raster)
  if (is.character(x))
  {
    fname <- path.expand(x)
  } else if(!hasValues(x))
  {
    stop("The provided object has no values!")
  } else if(raster:::.driver(x, warn=FALSE)!="gdal")
  {
    datFor <- raster:::.driver(x, warn=FALSE)
    
    if(datFor!="gdal")
    {
      if (verbose)
      {
        message("File in a non readable form for GDAL, converting...(you may change the default raster format in '?rasterOptions' to 'GTiff' or another GDAL supported format see 'gdal_drivers()')")
      }
      fname <- gdalTmpFile()
      x <- writeRaster(x,filename=fname)
    } else
    {
      fname <- path.expand(filename(x))
    }
  }
  return(fname)
}

gdal_gdalToRaster <- function(x)
{
  require(raster)
  if(!file.exists(x))
  {
    stop("Could not find file:", x)
  }
  
  nbands <- gdalinfo(x)[3]
  
  if(nbands==1)
  {
    return(raster(x))
  } else
  {
    return(brick(x))
  }
}
