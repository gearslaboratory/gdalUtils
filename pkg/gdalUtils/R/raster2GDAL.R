# TODO: Add comment
# 
# Author: jgrn307
###############################################################################


raster2GDAL <- function(Robject)
{
	if(is.Raster(Robject))
	{
		if(inMemory(Robject))
		{
			# Write it out and return
		}
		
		
		
		
	} else
	{
		return(Robject)
	}
	
	
}
