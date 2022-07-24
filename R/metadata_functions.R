#' Get useful dataset metadata on all available APIs as a data frame
#'
#' Scrapes {https://api.census.gov/data.json} and returns a dataframe
#' that includes: title, description, name, vintage, url, dataset type, and other useful fields.
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

	# Format variable names and values
	colnames(datasets) <- gsub("c_", "", colnames(datasets))
	datasets$name <- apply(datasets, 1, function(x) paste(x$dataset, collapse = "/"))
	datasets$url <- apply(datasets, 1, function(x) x$distribution$accessURL)

	names(datasets)[names(datasets) == "contactPoint.hasEmail"] <- "contact"

	# Add a dataset type variable built from binary variables
	datasets$type <- ifelse(datasets$isMicrodata %in% TRUE , "Microdata",
													ifelse(datasets$isTimeseries %in% TRUE, "Timeseries",
																 ifelse(datasets$isAggregate %in% TRUE, "Aggregate",
																 			 NA)))

	dt <- datasets[, c("title", "name", "vintage", "type", "temporal", "url", "modified", "description", "contact")]
	dt <- dt[order(-dt$vintage, dt$name),]
	return(dt)
}

#' Get information about a specific API as a data frame
#'
#' @param name API programmatic name - e.g. acs/acs5. See list of names with listCensusApis().
#' @param vintage Vintage (year) of dataset. Not required for timeseries APIs
#' @param type Type of metadata to return, either "variables", "geographies",
#' "groups", or "values". Default is variables.
#' @param group An optional variable group code, used to return metadata for a specific group
#' of variables only. This field is not used in all APIs.
#' @param variable_name A name of a specific variable used to return metadata about that
#' variable. This field is not used in all APIs.
#' @keywords metadata
#' @examples
#' \dontrun{
#'
#' # List the variables available in the Small Area Health Insurance Estimates.
#' sahie_variables <- listCensusMetadata(
#'   name = "timeseries/healthins/sahie",
#'   type = "variables")
#'  head(sahie_variables)
#'
#' # List the geographies available in the 5-year 2020 American Community Survey.
#' acs_geographies <- listCensusMetadata(
#'   name = "acs/acs5",
#'   vintage = 2020,
#'   type = "geographies")
#'  head(acs_geographies)
#'
#' # list the variable groups available in the 5-year 2020 American Community Survey.
#' acs_groups <- listCensusMetadata(
#'   name = "acs/acs5",
#'   vintage = 2020,
#'   type = "groups")
#'  head(acs_groups)
#'
#' # List the value labels of the NAICS2017 variable in the 2020 County
#' # Business Patterns dataset.
#' cbp_naics_values <- listCensusMetadata(
#'   name = "cbp",
#'   vintage = 2020,
#'   type = "values",
#'   variable = "NAICS2017")
#'  head(cbp_naics_values)
#'
#' # List of variables that are included in the B17020 group in the
#' # 5-year American Community Survey.
#' group_B17020 <- listCensusMetadata(
#'   name = "acs/acs5",
#'   vintage = 2017,
#'   type = "variables",
#'   group = "B17020")
#'  head(group_B17020)
#' }
#' @export
listCensusMetadata <-
	function(name,
					 vintage = NULL,
					 type = "variables",
					 group = NULL,
					 variable_name = NULL) {

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

				# Get the list of possible column names
				cols <- unique(unlist(lapply(raw$variables, names)))

				# Remove invalid dashes in variable names - new problem with Microdata APIs
				cols <- gsub("-", "_", cols)

				cols <- cols[!(cols %in% c("predicateOnly", "datetime", "validValues", "values"))]

				# REVIST THIS - unnecessarily complicated, can remove those columns later
				makeDf <- function(d) {
					names(d) <- gsub("-", "_", names(d))
					if ("validValues" %in% names(d)) {
						d$validValues <- NULL
					}
					if ("values" %in% names(d)) {
						d$values <- NULL
					}
					df <- data.frame(d)

					df[, setdiff(cols, names(df))] <- NA
					return(df)
				}

				dts <- lapply(raw$variables, function(x) if (!("predicateOnly" %in% names(x))) {
						makeDf(x)
					} else {x <- NULL}
				)
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
		} else if (type == "values") {
			u <- paste0(apiurl, "/variables/", variable_name, ".json")
			req <- httr::GET(u)
			# Check the API call for a valid response
			apiCheck(req)

			# If check didn't fail, parse the content
			raw <- apiParse(req)
			if (length(raw$values) == 0) {
				stop(paste("Values are not available for the selected variable:", variable_name))
			}
			dt <- utils::stack(raw$values$item)
			colnames(dt) <- c("label", "value")
			dt <- dt[, c("value", "label")]

		}	else {
			stop(paste('For "type", you entered: "', type, '". Did you mean "variables", "geography", "groups", or "values"?', sep = ""))
		}
		return(dt)
	}

