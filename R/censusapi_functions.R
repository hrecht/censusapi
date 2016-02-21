#' Return all available APIs as data frame
#'
#' @param none
#' @keywords metadata
#' @export
#' @examples apis <- listCensusApis()
#' listCensusApis()
listCensusApis <- function() {
  u <- 'http://api.census.gov/data.html'
  apis <- as.data.frame(XML::readHTMLTable(u))
  apis <- apis[,c(1:4,10)]
  colnames(apis) <- c("title", "description", "vintage", "name", "url")
  apis[] <- lapply(apis, as.character)
  return(apis)
}

#' Return list of variables or geographies available by api
#'
#' @param apiurl, type
#' @keywords metadata
#' @export
#' @examples vars2014 <- listCensusMetadata("http://api.census.gov/data/2014/acs5", "v")
#' @examples geos2014 <- listCensusMetadata("http://api.census.gov/data/2014/acs5", "g")
#' listCensusMetadata()
listCensusMetadata <- function(apiurl, type) {
  # Trim trailing ? or /
  lastchar <- substr(apiurl, nchar(apiurl), nchar(apiurl))
  if (lastchar=="?" | lastchar=="/") {
    apiurl <- substr(apiurl, 1, nchar(apiurl)-1)
  }
  
  if (type=="v") {
  	u <- paste(apiurl, "variables.html", sep="/")
  	df <- as.data.frame(XML::readHTMLTable(u))
  	colnames(df) <- c("name", "label", "concept", "required", "predicatetype")
  	df[] <- lapply(df, as.character)
  	return(df)
  }
  if (type=="g") {
  	u <- paste(apiurl, "geography.html", sep="/")
  	df <- as.data.frame(readHTMLTable(u))
  	colnames(df) <- c("reference_date", "geography_level", "geography_hierarchy")
  	df[] <- lapply(df, as.character)
  	return(df)
  }
  if (type != "v" | type !="g") {
  	print("Type options are 'v' or 'g'")
  }
}

# List of state fips (50 states + DC)
statesuse <- c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56)

#' Internal function: Get the API response, return a data frame
#'
#' @param apiurl, key, get, region
#' @keywords internal
#' @export
#' @examples none
#' getFunction()
getFunction <- function(apiurl, key, get, region) {
	api_call <- paste(apiurl, 
										'?key=', key, 
										'&get=', get,
										'&for=', region,
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
#' Retrieve data frame from the Census API
#'
#' Heavily based on work by Nicholas Nagle, https://rpubs.com/nnnagle/19337
#' @param apiurl, key, vars, region
#' @keywords api
#' @export
#' @examples myvars <- c("B01001_001E", "NAME", "B01002_001E", "B19013_001E", "B19001_001E", "B03002_012E")
#' @examples acs_2014_api <- 'http://api.census.gov/data/2014/acs5'
#' @examples df <- getCensus(acs_2014_api, key=censuskey, vars=myvars, region="tract:*&in=state:06")
#' listCensusMetadata()
getCensus <- function(apiurl, key, vars, region) {
	# Census API max vars per call = 50
	if(length(vars)>50){
		# Split vars into list
		vars <- split(vars, ceiling(seq_along(vars)/50))
		get <- lapply(vars, function(x) paste(x, sep='', collapse=","))
		data <- lapply(get, function(x) getFunction(apiurl, key, x, region))
		colnames <- unlist(lapply(data, names))
		data <- do.call(cbind,data)
		names(data) <- colnames
	} else {
		get <- paste(vars, sep='', collapse=',')
		data <- getFunction(apiurl, key, get, region)
	}
	# If there are any duplicate columns (ie if you put a variable in vars twice) remove the duplicates
	data <- data[, !duplicated(colnames(data))]
	# Reorder columns so that numeric fields follow non-numeric fields
	data <- data[,c(which(sapply(data, class)!='numeric'), which(sapply(data, class)=='numeric'))]
	return(data)
}