#' Internal function: Get the API response, return a data frame
#'
#' @param apiurl, key, get, region, time
#' @keywords internal
#' @export
#' @examples none
#' getFunction()
getFunction <- function(apiurl, key, get, region, regionin, time, date, period, monthly, category_code, data_type_code) {
	# Return API's built in error message if invalid call
	apiCheck <- function(req) {
		if (req$status_code==400) stop(httr::content(req, as = "text"), call. = FALSE)
		# Some time series don't give error messages, just don't resolve (e.g. SAIPE)
		if (req$status_code==204) stop("Error 204: No content. If using a time series API, check time period inputs - given time period may be unavailable.", call. = FALSE)
		if (identical(httr::content(req, as = "text"), "")) stop("No output to parse", call. = FALSE)
	}
	
	apiParse <- function (req) {
		raw <- jsonlite::fromJSON(httr::content(req, as = "text"))
		raw
	}
	responseFormat <- function(raw) {
		# Make first row the header
		colnames(raw) <- raw[1, ]
		raw <- raw[-1, ]  
		df <- data.frame(raw)
		# Make all columns character
		df[] <- lapply(df, as.character)
		# Make columns numeric if they have numbers in the column name - note some APIs use string var names
		value_cols <- grep("[0-9]", names(df), value=TRUE)
		for(col in value_cols) df[,col] <- as.numeric(df[,col])
		df	
	}
	
	# Assemble call
	req <- httr::GET(apiurl, query = list(key = key, get = get, "for" = region, "in" = regionin, category_code = category_code, data_type_code = data_type_code, time = time, DATE = date, PERIOD = period, MONTHLY = monthly))
	
	# Check the API call for a valid response
	apiCheck(req)
	
	# If check didn't fail, parse the content
	raw <- apiParse(req)
	
	# Format the response into a nice data frame
	df <- responseFormat(raw)
}
#' Retrieve Census data from a given API
#'
#' @param name API name - e.g. acs5. See list at http://api.census.gov/data.html
#' @param vintage Optional vintage of dataset, e.g. 2014
#' @param key Your Census API key, gotten from http://api.census.gov/data/key_signup.html
#' @param vars List of variables to get
#' @param region Geograpy to get
#' @param regionin Optional hierarchical geography to limit region
#' @param time Optional argument used for some time series APIs
#' @param date Optional argument used for some time series APIs
#' @param period Optional argument used for some time series APIs
#' @param monthly Optional argument used for some time series APIs
#' @param category_code Argument used in Economic Indicators Time Series API
#' @param data_type_code Argument used in Economic Indicators Time Series API
#' @keywords api
#' @export
#' @examples 
#' myvars <- c("B01001_001E", "NAME", "B01002_001E", "B19013_001E", "B19001_001E", "B03002_012E")
#' df <- getCensus(name="acs5", vintage=2014, key="YOURKEYHERE", vars=myvars, region="tract:*" regionin="state:06")
#' 
#' # Retrieve over 50 variables
#' myvars2 <- paste('B04004_', sprintf('%03i', seq(1, 105)), 'E', sep='')
#' df <- getCensus(name="acs5", vintage=2014, key="YOURKEYHERE", vars=myvars2, region="county*")
#' 
#' # Get time series data
#' saipe <- getCensus(name="timeseries/poverty/saipe", key=censuskey, vars=c("NAME", "SAEPOVRT0_17_PT", "SAEPOVRTALL_PT"), region="state:*", time=2011)
#' 
#' # Loop over all states using fips list included in package
#' tracts <- NULL
#' for (f in fips) {
#'	stateget <- paste("state:", f, sep="")
#'	temp <- getCensus(name="sf3", vintage=1990, key=censuskey, vars=c("P0070001", "P0070002", "P114A001"), region="tract:*", regionin = stateget)
#'	tracts <- rbind(tracts, temp)
#' }
getCensus <- function(name, vintage=NULL, key, vars, region, regionin=NULL, time=NULL, date=NULL, period=NULL, monthly=NULL,  category_code=NULL, data_type_code=NULL) {
	constructURL <- function(name, vintage) {
		if (is.null(vintage)) {	
			apiurl <- paste("http://api.census.gov/data", name, sep="/")
		} else {
			apiurl <- paste("http://api.census.gov/data", vintage, name, sep="/")
		}
		
		# Handle messy urls
		lastchar <- substr(apiurl, nchar(apiurl), nchar(apiurl))
		if (lastchar=="?" | lastchar=="/") {
			apiurl <- substr(apiurl, 1, nchar(apiurl)-1)
		}
		apiurl
	}
	
	if (missing(key)) {
		stop("'key' argument is missing. A Census API key is required and can be requested at http://api.census.gov/data/key_signup.html")
	}
	
	apiurl <- constructURL(name, vintage)

	# Census API max vars per call = 50
	# Splitting function based on work by Nicholas Nagle, https://rpubs.com/nnnagle/19337
	if(length(vars)>50){
		# Split vars into list
		vars <- split(vars, ceiling(seq_along(vars)/50))
		get <- lapply(vars, function(x) paste(x, sep='', collapse=","))
		data <- lapply(get, function(x) getFunction(apiurl, key, x, region, regionin, time, date, period, monthly, category_code, data_type_code))
		colnames <- unlist(lapply(data, names))
		data <- do.call(cbind,data)
		names(data) <- colnames
	} else {
		get <- paste(vars, sep='', collapse=',')
		data <- getFunction(apiurl, key, get, region, regionin, time, date, period, monthly, category_code, data_type_code)
	}
	# If there are any duplicate columns (ie if you put a variable in vars twice) remove the duplicates
	data <- data[, !duplicated(colnames(data))]
	# Reorder columns so that numeric fields follow non-numeric fields
	data <- data[,c(which(sapply(data, class)!='numeric'), which(sapply(data, class)=='numeric'))]
	return(data)
}