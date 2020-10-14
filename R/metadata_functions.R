#' Get dataset metadata on all available APIs as a data frame
#'
#' Scrapes {https://api.census.gov/data.json} and returns a dataframe
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
	u <- "https://api.census.gov/data.json"
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
#' @param name API name - e.g. acs5. See list at https://api.census.gov/data.html
#' @param vintage Vintage of dataset, e.g. 2014 - not required for timeseries APIs
#' @param type Type of metadata to return, either "variables", "geographies" or "geography", or
#' "groups". Default is variables.
#' @param group An optional variable group code, used to return metadata for a specific group
#' of variables only.
#' @keywords metadata
#' @export
#' @examples
#' \donttest{sahie_vars <- listCensusMetadata(name = "timeseries/healthins/sahie, type = "variables")
#' head(sahie_vars)
#'
#' acs_geos <- listCensusMetadata(name = "acs/acs5", vintage = 2017, type = "geographies")
#' head(acs_geos)
#'
#' acs_groups <- listCensusMetadata(name = "acs/acs5", vintage = 2017, type = "groups")
#' head(acs_groups)
#'
#' group_B17020 <- listCensusMetadata(name = "acs/acs5",
#' vintage = 2017,
#' type = "variables",
#' group = "B17020")
#' head(group_B17020)}
listCensusMetadata <-
	function(name,
					 vintage = NULL,
					 type = "variables",
					 group = NULL) {

		constructURL <- function(name, vintage) {
			if (is.null(vintage)) {
				apiurl <- paste("https://api.census.gov/data", name, sep="/")
			} else {
				apiurl <- paste("https://api.census.gov/data", vintage, name, sep="/")
			}

			# Handle messy urls
			lastchar <- substr(apiurl, nchar(apiurl), nchar(apiurl))
			if (lastchar=="?" | lastchar=="/") {
				apiurl <- substr(apiurl, 1, nchar(apiurl)-1)
			}
			apiurl
		}

		# Return API's built in error message if invalid call
		apiCheck <- function(req) {
			if (!(req$status_code %in% c(200, 201, 202))) {
				if (req$status_code == 404) {
					stop(paste("Invalid metadata request, (404) not found.",
							 "\n Your API call was: ", print(req$url)), call. = FALSE)
				} else if (req$status_code==400) {
					stop(paste("The Census Bureau returned the following error message:\n", req$error_message,
										 "\n Your API call was: ", print(req$url)))
				} else if (req$status_code==204) {
					stop(paste("204, no content was returned. \n Your API call was: ", print(req$url)), call. = FALSE)
				} else if (identical(httr::content(req, as = "text"), "")) {
					stop(paste("No output to parse. \n Your API call was: ", print(req$url)), call. = FALSE)
				}
			}
		}

		apiParse <- function (req) {
			if (jsonlite::validate(httr::content(req, as="text"))[1] == FALSE) {
				error_message <- (gsub("<[^>]*>", "", httr::content(req, as="text")))
				stop(paste("The Census Bureau returned the following error message:\n", error_message, "\nYour api call was: ", req$url))
			} else {
				raw <- jsonlite::fromJSON(httr::content(req, as = "text"))
			}
		}

		apiurl <- constructURL(name, vintage)

		if (type %in% c("variables", "v")) {
			# Too nested and irregular for automatic conversion

			if (!is.null(group)) {
				u <- paste(apiurl, "/groups/", group, ".json", sep="")

				req <- httr::GET(u)
				# Check the API call for a valid response
				apiCheck(req)

				# If check didn't fail, parse the content
				raw <- apiParse(req)

				cols <- unique(unlist(lapply(raw$variables, names)))
				makeDf <- function(d) {
					df <- data.frame(d)
					df[, setdiff(cols, names(df))] <- NA
					return(df)
				}
				dts <- lapply(raw$variables, function(x) {makeDf(x)})

			} else {
				u <- paste(apiurl, "variables.json", sep="/")
				req <- httr::GET(u)
				# Check the API call for a valid response
				apiCheck(req)

				# If check didn't fail, parse the content
				raw <- apiParse(req)
				# JSON of variables has irregular structure that gets standardized in the HTML view
				# Particularly the datetime filed used in some APIs
				# Generally, predicateOnly = parameter, exclude predicateOnly (parameters)

				# Manual fill with NAs as needed to avoid adding a dplyr::bind_rows or similar dependency
				cols <- unique(unlist(lapply(raw$variables, names)))
				cols <- cols[!(cols %in% c("predicateOnly", "datetime", "validValues", "values"))]
				makeDf <- function(d) {
					if("validValues" %in% names(d)) {
						d$validValues <- NULL
					}
					if("values" %in% names(d)) {
						d$values <- NULL
					}
					df <- data.frame(d)
					df[, setdiff(cols, names(df))] <- NA
					return(df)
				}
				dts <- lapply(raw$variables, function(x) if(!("predicateOnly" %in% names(x))) {makeDf(x)} else {x <- NULL})
			}
			temp <- Filter(is.data.frame, dts)
			dt <- do.call(rbind, temp)

			# Clean up
			dt <- cbind(name = row.names(dt), dt)
			row.names(dt) <- NULL
			dt[] <- lapply(dt, as.character)


		} else if (type %in% c("geography", "geographies", "g")) {
			u <- paste(apiurl, "geography.json", sep="/")
			req <- httr::GET(u)
			# Check the API call for a valid response
			apiCheck(req)

			# If check didn't fail, parse the content
			raw <- apiParse(req)
			dt <- raw$fips
		} else if (type %in% c("groups", "group")) {
			u <- paste(apiurl, "groups.json", sep="/")
			req <- httr::GET(u)
			# Check the API call for a valid response
			apiCheck(req)

			# If check didn't fail, parse the content
			raw <- apiParse(req)
			dt <- raw[[1]]
			if (is.null(dim(dt))) {
				stop("Groups are not available for the selected API endpoint.")
			}
		}	else {
			stop(paste('For "type", you entered: "', type, '". Did you mean "variables" or "geography" or "groups"?', sep = ""))
		}
		return(dt)
	}
