#' @export

sample_GDAL_command <- function(src_dataset,dst_dataset,ot,strict,of="Gtiff",
		b,mask,expand,outsize,scale,unscale,srcwin,projwin,epo,eco,
		a_srs,a_ullr,a_nodata,mo,co,gcp,q,sds,stats,
		additional_commands,
		modis_sds_index,
		output_Raster=FALSE,verbose=FALSE)
	
{
	parameter_values <- as.list(environment())
#	defined_variables <- names(all_variables)[sapply(all_variables,function(X) class(X) != "name")]
	
	# Put any mods to the parameters up here, like modis_sds_index modifies src_dataset
	
	# Place all gdal function variables into these groupings:
	parameter_variables <- list(
			logical = list(
					varnames <- c("strict","unscale","epo","eco","q","sds","stats")),
			vector = list(
					varnames <- c("outsize","scale","srcwin","projwin","a_ullr","gcp")),
			scalar = list(
					varnames <- c("a_nodata")),
			character = list(
					varnames <- c("ot","of","mask","expand","a_srs","src_dataset","dst_dataset")),
			repeatable = list(
					varnames <- c("b","mo","co"))
	#,
	#		noflag = list(
	#				varnames <- c("src_dataset","dst_dataset"))
			)
			
		parameter_order <- c(
			"strict","unscale","epo","eco","q","sds","stats",
			"outsize","scale","srcwin","projwin","a_ullr","gcp",
			"a_nodata",
			"ot","of","mask","expand","a_srs",
			"b","mo","co",
			"src_dataset","dst_dataset")
	
	parameter_noflags <- c("src_dataset","dst_dataset")
	
	# Get this from get_gdal_installation
	executable <- file.path(gdal_path()[1],"gdal_translate")# [1] is prov!
	
	cmd <- gdal_cmd_builder(
		executable=executable,
		parameter_variables=parameter_variables,
		parameter_values=parameter_values,
		parameter_order=parameter_order,
		parameter_noflags=parameter_noflags)
	
	# Run the command here:
	print(cmd)
}