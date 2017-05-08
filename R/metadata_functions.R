#' Get dataset metadata on all available APIs as a data frame
#'
#' Scrapes {http://api.census.gov/data.json} and returns a dataframe
#' that includes: title, name, vintage (where applicable), url, isTimeseries (binary),
#' temporal (helpful for some time series), description, modified date
#'
#' @keywords metadata
#' @export
#' @examples
#' apis <- listCensusApis()
#' head(apis)
listCensusApis <- function() {
	# Get data.json
	u <- "http://api.census.gov/data.json"
	raw <- jsonlite::fromJSON(u)
	datasets <- jsonlite::flatten(raw$dataset)

	# Format for user
	colnames(datasets) <- gsub("c_", "", colnames(datasets))
	datasets$name <- apply(datasets, 1, function(x) paste(x$dataset, collapse = "/"))
	datasets$url <- apply(datasets, 1, function(x) x$distribution$accessURL)

	dt <- datasets[, c("title", "name", "vintage", "url", "isTimeseries", "temporal", "description", "modified")]
	dt <- dt[order(dt$name, dt$vintage),]
	return(dt)
}

#' Get variable or geography metadata for a given API as a data frame
#'
#' @param name API name - e.g. acs5. See list at http://api.census.gov/data.html
#' @param vintage Vintage of dataset, e.g. 2014 - not required for timeseries APIs
#' @param type Type of metadata to return, either "variables" or "v" to return variables
#' or "geographies" or "g" to return geographies. Default is variables.
#' @keywords metadata
#' @export
#' @examples
#' varsbds<- listCensusMetadata(name="timeseries/bds/firms", type = "v")
#' head(varsbds)
#'
#' geosbds <- listCensusMetadata(name="timeseries/bds/firms", type = "g")
#' head(geosbds)
#'
#' geosacs <- listCensusMetadata(name="acs5", vintage = 2015, type = "g")
#' head(geosacs)
listCensusMetadata <- function(name, vintage=NULL, type="variables") {
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

	if (type %in% c("variables", "v")) {
		u <- paste(apiurl, "variables.json", sep="/")
		raw <- jsonlite::fromJSON(u)
		dt <- do.call(dplyr::bind_rows, lapply(raw$variables, data.frame))
		dt$name <- names(raw$variables)

	} else if (type %in% c("geography", "geographies", "g")) {
		u <- paste(apiurl, "geography.json", sep="/")
		raw <- jsonlite::fromJSON(u)
		dt <- raw$fips
	} else {
		stop(paste('For "type", you entered: "', type, '". Did you mean "variables" or "geography"?', sep = ""))
	}
	return(dt)
}
