#' Internal function: Get the API response, return a data frame
#'
#' @param apiurl, key, get, region, time
#' @keywords internal
#' @export
#' @examples none
#' getFunction()
getFunction <- function(apiurl, key, get, region, time) {
	# SAHIE time series API uses time arg
	if (is.null(time)) {
		timearg <- ''
	} else {
		if (apiurl=='http://api.census.gov/data/timeseries/healthins/sahie' & !(time %in% c(2006:2013))) {
			stop('The SAHIE API has data for years 2006 - 2013')
		}
		if (apiurl=='http://api.census.gov/data/timeseries/poverty/saipe' & !(time %in% c(1989, 1993, 1995:2014))) {
			stop('The SAIPE API has data for years 1989, 1993, 1995-2014')
		}
		timearg <- paste('&time=', time, sep='')
	}
	api_call <- paste(apiurl, 
										'?key=', key, 
										'&get=', get,
										'&for=', region,
										timearg,
										sep='')
	raw <- jsonlite::fromJSON(api_call)
	# Make first row the header
	colnames(raw) <- raw[1, ]
	raw <- raw[-1, ]  
	df <- data.frame(raw)
	# Make all columns character
	df[] <- lapply(df, as.character)
	# Make columns numeric if they have numbers in the column name - note some APIs use string var names
	value_cols <- grep("[0-9]", names(df), value=TRUE)
	for(col in value_cols) df[,col] <- as.numeric(df[,col])
	return(df)
}
#' Retrieve Census data from a given API
#'
#' Heavily based on work by Nicholas Nagle, https://rpubs.com/nnnagle/19337
#' @param apiurl Root URL for a Census API - see list at http://api.census.gov/data.html
#' @param key Your Census API key, gotten from http://api.census.gov/data/key_signup.html
#' @param vars List of variables to get
#' @param region Geograpy to get
#' @param time Optional time argument for time series APIs, generally a year
#' @keywords api
#' @export
#' @examples 
#' acs_2014_api <- 'http://api.census.gov/data/2014/acs5'
#' myvars <- c("B01001_001E", "NAME", "B01002_001E", "B19013_001E", "B19001_001E", "B03002_012E")
#' df <- getCensus(acs_2014_api, key="YOURKEYHERE", vars=myvars, region="tract:*&in=state:06")
#' 
#' myvars2 <- paste('B04004_', sprintf('%03i', seq(1, 105)), 'E', sep='')
#' df <- getCensus(acs_2014_api, key="YOURKEYHERE", vars=myvars2, region="county*")
#' 
#' # Loop over all states - using fips list included in package
#' tracts <- NULL
#' for (f in fips) {
#'	regionget <- paste("tract:*&in=state:", f, sep="")
#'	temp <- getCensus(acs_2014_api, key=censuskey, vars=myvars, region=regionget)
#'	tracts <- rbind(tracts, temp)
#' }
getCensus <- function(apiurl, key, vars, region, time=NULL) {
	if (missing(key)) {
		stop("'key' argument is missing. A Census API key is required and can be requested at http://api.census.gov/data/key_signup.html")
	}
	# Census API max vars per call = 50
	if(length(vars)>50){
		# Split vars into list
		vars <- split(vars, ceiling(seq_along(vars)/50))
		get <- lapply(vars, function(x) paste(x, sep='', collapse=","))
		data <- lapply(get, function(x) getFunction(apiurl, key, x, region, time))
		colnames <- unlist(lapply(data, names))
		data <- do.call(cbind,data)
		names(data) <- colnames
	} else {
		get <- paste(vars, sep='', collapse=',')
		data <- getFunction(apiurl, key, get, region, time)
	}
	# If there are any duplicate columns (ie if you put a variable in vars twice) remove the duplicates
	data <- data[, !duplicated(colnames(data))]
	# Reorder columns so that numeric fields follow non-numeric fields
	data <- data[,c(which(sapply(data, class)!='numeric'), which(sapply(data, class)=='numeric'))]
	return(data)
}