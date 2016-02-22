#' Return all available APIs as data frame
#'
#' @keywords metadata
#' @export
#' @examples
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
#' @param apiurl Root URL for a Census API
#' @param type: 'v' for variables or 'g' for geographies
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