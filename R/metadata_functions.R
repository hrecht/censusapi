#' Get dataset metadata on all available APIs as a data frame
#'
#' Scrapes {http://api.census.gov/data.html}
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
	apis$name <- gsub("\U203A ", "/", apis$name)
	apis[apis=="N/A"] <- NA
	apis$vintage <- as.numeric(apis$vintage)
	return(apis)
}

#' Get variable or geography metadata for a given API as a data frame
#'
#' @param name API name - e.g. acs5. See list at http://api.census.gov/data.html
#' @param vintage Vintage of dataset, e.g. 2014 - not required for timeseries APIs
#' @param type Type of metadata to return, either 'v' for variables or 'g' for geographies. Default = variables.
#' @keywords metadata
#' @export
#' @examples
#' vars2014 <- listCensusMetadata(name="acs5", vintage=2014, "v")
#' geos2014 <- listCensusMetadata(name="acs5", vintage=2014, "g")
listCensusMetadata <- function(name, vintage=NULL, type="v") {
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
	apiurl <- constructURL(name, vintage)

	if (type=="v") {
		u <- paste(apiurl, "variables.html", sep="/")
		tables <- XML::readHTMLTable(u)
		if (length(tables)==1) {
			df <- as.data.frame(tables)
		} else {
			# this should not be needed
			df <- tables[[1]]
		}
		colnames(df) <- c("name", "label", "concept", "required", "predicatetype")
		df[] <- lapply(df, as.character)
		return(df)
	}
	if (type=="g") {
		u <- paste(apiurl, "geography.html", sep="/")
		tables <- XML::readHTMLTable(u)
		if (length(tables)==1) {
			df <- as.data.frame(tables)
		} else {
			# this is very rare - 2010 sf1 only
			df <- tables[[1]]
		}
		colnames(df) <- c("reference_date", "geography_level", "geography_hierarchy")
		df[] <- lapply(df, as.character)
		return(df)
	}
	if (type != "v" | type !="g") {
		print("Type options are 'v' or 'g'")
	}
}
