python_path <- function(
		search_path,
		ignore.options=FALSE,
		ignore.which=FALSE,
		ignore.common=FALSE,
		force_full_scan = FALSE, 
		checkValidity, 
		search_path_recursive=FALSE,
		verbose = FALSE)
{
	owarn <- getOption("warn")
	options(warn=-2)
	on.exit(options(warn=owarn))
	
	if(missing(checkValidity))
	{
		if(is.null(getOption("gdalUtils_gdalPath"))) checkValidity=TRUE else checkValidity=FALSE
	}
	
	path <- NULL
	# Rescan will override everything.
	if(!force_full_scan)
	{
		# Check options first.
		if(!ignore.options)
		{
			if(verbose) message("Checking the gdalUtils_gdalPath option...")
			option_paths <- unlist(
					sapply(getOption("gdalUtils_pythonPath"),function(x) return(x$path)))
			if(!is.null(option_paths) && checkValidity)
			{
				option_paths_check <- gdal_check_validity(option_paths)
				option_paths <- option_paths[option_paths_check]
			}
			path <- c(path,option_paths)
		}
		
		# Next try Sys.which unless ignored:
		if(!ignore.options && length(path)==0)
		{
			if(verbose) message("Checking Sys.which...")
			Sys.which_path <- dirname(Sys.which("python.exe"))
			if(Sys.which_path=="") Sys.which_path <- NULL
			if(!is.null(Sys.which_path) && checkValidity)
			{
				Sys.which_path_check <- gdal_check_validity(Sys.which_path)
				Sys.which_path <- Sys.which_path[Sys.which_path_check]
			}
			path <- c(path,Sys.which_path)
		}
		
		# Next, try scanning the search path
		if(!missing(search_path) && length(path)==0)
		{
			if(verbose) message("Checking the search path...")
			search_paths <- normalizePath(dirname(
							list.files(path=search_path,pattern="^python.exe$",
									recursive=search_path_recursive,full.names=TRUE)))
			if(length(search_paths)==0) search_paths <- NULL
			if(!is.null(search_paths) && checkValidity)
			{
				search_paths_check <- gdal_check_validity(search_paths)
				search_paths <- search_paths[search_paths_check]
			}
			path <- c(path,search_paths)
			
		}
		
		# If nothing is still found, look in common locations
		if(!ignore.common && length(path)==0)
		{
			if(verbose) message("Checking common locations...")
			if (.Platform$OS=="unix")
			{
				common_locations <- c(
						# UNIX systems
						"/usr/bin",
						"/usr/local/bin",
						# Mac
						# Kyngchaos frameworks:
						"/Library/Frameworks/GDAL.framework/Programs",
						# MacPorts:
						"/opt/local/bin"
				)
			}
			
			if (.Platform$OS=="windows")
			{
				common_locations <- c(
						"C:\\Program Files",
						"C:\\Program Files (x86)",
						"C:\\OSGeo4W"
				)
			}
			
			if(length(common_locations != 0))
			{
				common_paths <- unlist(sapply(common_locations,
								function(x)
								{
									search_common_paths <- normalizePath(dirname(
													list.files(path=x,pattern="^python.exe$",recursive=TRUE,full.names=TRUE)))
									return(search_common_paths)
								}))
				if(length(common_paths)==0) common_paths <- NULL
				if(!is.null(common_paths) && checkValidity)
				{
					common_paths_check <- gdal_check_validity(common_paths)
					common_paths <- common_paths[common_paths_check]
				}
				path <- c(path,common_paths)
			}
		}
		if(length(path)==0)
		{
			force_full_scan=TRUE
		}
	}
	
	if(force_full_scan)
	{
		if(verbose) message("Scanning your root-dir for available GDAL installations,... This could take some time...")
		if (.Platform$OS=="unix")
		{
			root_dir <- "/"	
		}
		
		if (.Platform$OS=="windows")
		{
			root_dir <- "C:\\"
		}
		
		search_full_path <- normalizePath(dirname(
						list.files(path=root_dir,pattern="^python.exe$",
								recursive=TRUE,full.names=TRUE)))
		if(length(search_full_path)==0) search_full_path <- NULL
		if(!is.null(search_full_path) && checkValidity)
		{
			search_full_path_check <- gdal_check_validity(search_full_path)
			search_full_path <- search_full_path[search_full_path_check]
		}
		path <- c(path,search_paths)
	}
	
	if(length(path)==0)
	{
		#add QGIS?
		stop("No GDAL installation found. Please install 'gdal' before continuing:\n\t- www.gdal.org (no HDF4 support!)\n\t- www.trac.osgeo.org/osgeo4w/ (with HDF4 support RECOMMENDED)\n\t- www.fwtools.maptools.org (with HDF4 support)\n") # why not stop?
	}
	
	return(correctPath(path))
}

python_version_script <- "D:\\Users\\jgrn\\Documents\\code\\workspace\\gdalutils\\pkg\\gdalUtils\\inst\\external\\python_version.py"
python_exec <- paste(moo[2],"python.exe",sep="")
python_cmd <- paste(python_exec,python_version_script)
python_version_raw <- system(python_cmd,intern=TRUE)
python_version_raw_processed <- strsplit(gsub(" ","",strsplit(strsplit(strsplit(python_version_raw,"\\(")[[1]],"\\)")[[2]],",")[[1]]),"=")
python_version <- paste(python_version_raw_processed[[1]][2],python_version_raw_processed[[2]][2],python_version_raw_processed[[3]][[2]],sep=".")


executable <- normalizePath(list.files(
				getOption("gdalUtils_gdalPath")[[1]]$path,
				"gdal_polygonize.py",full.names=TRUE))

polygonize_cmd <- paste(qm(python_exec),qm(executable))