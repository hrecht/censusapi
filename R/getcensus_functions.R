#' Internal function: Get the API response, return a data frame
#'
#' @param apiurl, key, get, region, time
#' @keywords internal
#' @export
#' @examples none
#' getFunction()
getFunction <- function(apiurl, key, get, region, time, date, period, monthly) {
	# Assemble call
	req <- httr::GET(apiurl, query = list(key = key, get = get, "for"=region, time = time, DATE = date, PERIOD = period, MONTHLY = monthly))
	text <- content(req, as = "text")
	# Return API's built in error message if invalid call
	if (req$status_code==400) stop(text, call. = FALSE)
	raw <- jsonlite::fromJSON(text)
	
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
#' @param time Optional argument used for some time series APIs
#' @param date Optional argument used for some time series APIs
#' @param period Optional argument used for some time series APIs
#' @param monthly Optional argument used for some time series APIs
#' @keywords api
#' @export
#' @examples 
#' acs_2014_api <- 'http://api.census.gov/data/2014/acs5'
#' myvars <- c("B01001_001E", "NAME", "B01002_001E", "B19013_001E", "B19001_001E", "B03002_012E")
#' df <- getCensus(acs_2014_api, key="YOURKEYHERE", vars=myvars, region="tract:*&in=state:06")
#' 
#' # Retrieve over 50 variables
#' myvars2 <- paste('B04004_', sprintf('%03i', seq(1, 105)), 'E', sep='')
#' df <- getCensus(acs_2014_api, key="YOURKEYHERE", vars=myvars2, region="county*")
#' 
#' # Get time series data
#' saipe_api <- 'http://api.census.gov/data/timeseries/poverty/saipe'
#' saipe <- getCensus(saipe_api, key=censuskey, vars=c("NAME", "SAEPOVRT0_17_PT", "SAEPOVRTALL_PT"), region="state:*", time=2011)
#' 
#' # Loop over all states using fips list included in package
#' tracts <- NULL
#' for (f in fips) {
#'	regionget <- paste("tract:*&in=state:", f, sep="")
#'	temp <- getCensus(acs_2014_api, key=censuskey, vars=myvars, region=regionget)
#'	tracts <- rbind(tracts, temp)
#' }
getCensus <- function(apiurl, key, vars, region, time=NULL, date=NULL, period=NULL, monthly=NULL) {
	if (missing(key)) {
		stop("'key' argument is missing. A Census API key is required and can be requested at http://api.census.gov/data/key_signup.html")
	}
	
	# Handle messy urls
	lastchar <- substr(apiurl, nchar(apiurl), nchar(apiurl))
	if (lastchar=="?" | lastchar=="/") {
		apiurl <- substr(apiurl, 1, nchar(apiurl)-1)
	}
	
	# Census API max vars per call = 50
	if(length(vars)>50){
		# Split vars into list
		vars <- split(vars, ceiling(seq_along(vars)/50))
		get <- lapply(vars, function(x) paste(x, sep='', collapse=","))
		data <- lapply(get, function(x) getFunction(apiurl, key, x, region, time, date, period, monthly))
		colnames <- unlist(lapply(data, names))
		data <- do.call(cbind,data)
		names(data) <- colnames
	} else {
		get <- paste(vars, sep='', collapse=',')
		data <- getFunction(apiurl, key, get, region, time, date, period, monthly)
	}
	# If there are any duplicate columns (ie if you put a variable in vars twice) remove the duplicates
	data <- data[, !duplicated(colnames(data))]
	# Reorder columns so that numeric fields follow non-numeric fields
	data <- data[,c(which(sapply(data, class)!='numeric'), which(sapply(data, class)=='numeric'))]
	return(data)
}