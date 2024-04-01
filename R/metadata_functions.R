#' Get general information about available datasets
#'
#' Scrapes https://api.census.gov/data.json and returns a dataframe that
#' includes columns for dataset title, description, name, vintage, url, dataset
#' type, and other useful fields.
#'
#' @keywords metadata
#' @param name Optional complete or partial API dataset programmatic name. For
#'   example, "acs", "acs/acs5", "acs/acs5/subject". If using a partial name,
#'   this needs to be the left-most part of the dataset name before `/`, e.g.
#'   "timeseries/eits" or "dec" or "acs/acs5".
#' @param vintage Optional vintage (year) of dataset.
#' @examples
#' \dontrun{
#' # Get information about every dataset available in the APIs
#' apis <- listCensusApis()
#' head(apis)
#'
#' # Get information about all vintage 2022 datasets
#' apis_2022 <- listCensusApis(vintage = 2022)
#' head(apis_2022)
#'
#' # Get information about all timeseries datasets
#' apis_timeseries <- listCensusApis(name = "timeseries")
#' head(apis_timeseries)
#'
#' # Get information about 2020 Decennial Census datasets
#' apis_decennial_2020 <- listCensusApis(name = "dec", vintage = 2020)
#' head(apis_decennial_2020)
#'
#' # Get information about one particular dataset
#' api_sahie <- listCensusApis(name = "timeseries/healthins/sahie")
#' head(api_sahie)
#' }
#'
#' @export
listCensusApis <- function(name = NULL,
													 vintage = NULL) {
	constructURL <- function(name, vintage) {
			# Get data.json
		if (is.null(name) & is.null(vintage)) {
			u <- "https://api.census.gov/data.json"
		} else if (is.null(vintage) & !is.null(name)) {
			u <- paste0("https://api.census.gov/data/", name,	".json")
		} else if (is.null(name) & !is.null(vintage)) {
			u <- paste0("https://api.census.gov/data/", vintage, ".json")
		} else if (!is.null(name) & !is.null(vintage)) {
			u <- paste0("https://api.census.gov/data/", vintage, "/", name, ".json")
		}
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

	u <- constructURL(name = name, vintage = vintage)
	req <- httr::GET(u)
	# Check the API call for a valid response
	apiCheck(req)

	# If check didn't fail, parse the content
	raw <- apiParse(req)

	#raw <- jsonlite::fromJSON(u)
	datasets <- jsonlite::flatten(raw$dataset)

	# Format variable names and values
	colnames(datasets) <- gsub("c_", "", colnames(datasets))
	datasets$name <- apply(datasets, 1, function(x) paste(x$dataset, collapse = "/"))
	datasets$url <- apply(datasets, 1, function(x) x$distribution$accessURL)

	names(datasets)[names(datasets) == "contactPoint.hasEmail"] <- "contact"

	# Add a dataset type variable built from binary variables
	# If requesting a subset of datasets it won't have all of these fields so assign
	# values one by one
	datasets$type <- NA
	if ("isMicrodata" %in% colnames(datasets)) {
		datasets$type <- ifelse(datasets$isMicrodata %in% TRUE, "Microdata", datasets$type)
	}
	if ("isAggregate" %in% colnames(datasets)) {
		datasets$type <- ifelse(datasets$isAggregate %in% TRUE, "Aggregate", datasets$type)
	}
	if ("isTimeseries" %in% colnames(datasets)) {
		datasets$type <- ifelse(datasets$isTimeseries %in% TRUE, "Timeseries", datasets$type)
	}

	# Keep only valuable columns - many are not useful (empty or the same for all datasets)
	if ("vintage" %in% colnames(datasets)) {
		dt <- datasets[, c("title", "name", "vintage", "type", "temporal",
											 "spatial", "url", "modified", "description", "contact")]

		# Give some logic to the row ordering
		dt <- dt[order(-dt$vintage, dt$name),]
	} else {
		dt <- datasets[, c("title", "name", "type", "temporal", "spatial",
											 "url", "modified", "description", "contact")]
		dt <- dt[order(dt$name),]
	}
	dt$contact <- gsub("mailto:", "", dt$contact)

	rownames(dt) <- NULL
	return(dt)
}

#' Get metadata about a specific API endpoint, including available variables,
#' geographies, variable groups, and value labels
#'
#' @param name API programmatic name - e.g. acs/acs5. Use `listCensusApis()` to
#'   see valid dataset names.
#' @param vintage Vintage (year) of dataset. Not required for timeseries APIs.
#' @param type Type of metadata to return. Options are:
#'
#'   * "variables" (default) - list of variable names and descriptions
#'   for the dataset.
#'   * "geographies" - available geographies.
#'   * "groups" - available variable groups. Only available
#'   for some datasets.
#'   * "values" - encoded value labels for a given variable. Pair with
#'   "variable_name". Only available for some datasets.
#' @param group An optional variable group code, used to return metadata for a
#'   specific group of variables only. Variable groups are not used for all
#'   APIs.
#' @param variable_name A name of a specific variable used to return value
#'   labels for that variable. Value labels are not used for all APIs.
#' @param include_values Use with `type = "variables"`. Include value metadata
#'   for all variables in a dataset if value metadata exists. Default is
#'   "FALSE".
#' @keywords metadata
#' @examples
#' \dontrun{
#' # type: variables
#' # List the variables available in the Small Area Health Insurance Estimates.
#' variables <- listCensusMetadata(
#'   name = "timeseries/healthins/sahie",
#'   type = "variables")
#'  head(variables)
#'
#' # type: variables for a single variable group
#' # List the variables that are included in the B17020 group in the
#' # 5-year American Community Survey.
#' variable_group <- listCensusMetadata(
#'   name = "acs/acs5",
#'   vintage = 2022,
#'   type = "variables",
#'   group = "B17020")
#'  head(variable_group)
#'
#' # type: variables, with value labels
#' # Create a data dictionary with all variable names and encoded values for
#' # a microdata API.
#' variable_values <- listCensusMetadata(
#' 	name = "cps/voting/nov",
#' 	vintage = 2020,
#' 	type = "variables",
#' 	include_values = TRUE)
#' head(variable_values)
#'
#' # type: geographies
#' # List the geographies available in the 5-year American Community Survey.
#' geographies <- listCensusMetadata(
#'   name = "acs/acs5",
#'   vintage = 2022,
#'   type = "geographies")
#'  head(geographies)
#'
#' # type: groups
#' # List the variable groups available in the 5-year American Community Survey.
#' groups <- listCensusMetadata(
#'   name = "acs/acs5",
#'   vintage = 2022,
#'   type = "groups")
#'  head(groups)
#'
#' # type: values for a single variable
#' # List the value labels of the NAICS2017 variable in the County Business Patterns dataset.
#' naics_values <- listCensusMetadata(
#'   name = "cbp",
#'   vintage = 2021,
#'   type = "values",
#'   variable = "NAICS2017")
#'  head(naics_values)
#' }
#' @export
listCensusMetadata <-
	function(name,
					 vintage = NULL,
					 type = "variables",
					 group = NULL,
					 variable_name = NULL,
					 include_values = FALSE) {

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

		if (type %in% c("variables")) {
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

				# Remove invalid dashes in variable names - problem present in Microdata APIs
				cols <- gsub("-", "_", cols)

				if (include_values == FALSE | !("values" %in% cols)) {

					# Warn the user if they've asked for value labels but none are present
					if (include_values == TRUE & !("values" %in% cols)) {
						warning("You've set `include_values` to TRUE but this dataset does not contain variable values. Variable values will not be returned")
					}
					cols <- cols[!(cols %in% c("validValues", "values", "datetime"))]

					# Remove attributes that have nested lists
					makeDf <- function(d) {
						names(d) <- gsub("-", "_", names(d))
						if ("validValues" %in% names(d)) {
							d$validValues <- NULL
						}
						if ("values" %in% names(d)) {
							d$values <- NULL
						}
						if ("datetime" %in% names(d)) {
							d$datetime <- NULL
						}
						df <- data.frame(d)

						df[, setdiff(cols, names(df))] <- NA
						return(df)
					}

					dts <- lapply(raw$variables, makeDf)

				} else if (include_values == TRUE) {

			  	# Prepare for value code and label if the value metadata is present
					if ("values" %in% cols) {
						# print("VALUES ARE PRESENT")
						cols <- c(cols, "values_code", "values_label")
						cols <- cols[cols != "values"]
					}

					makeDf <- function(d) {
						names(d) <- gsub("-", "_", names(d))

						# As of right now, not using the "range" metadata in some of the microdata,
						# only item labels
						if ("values" %in% names(d) & "item" %in% names(d$values)) {
							# print(("YES VALUES META")
							# Make data frame of value labels
							temp_vals <- utils::stack(d$values$item)

							# Column cleaning
							colnames(temp_vals) <- c("label", "code")
							temp_vals <- temp_vals[, c("code", "label")]
							# Use character, not factor
							temp_vals$code <- as.character(temp_vals$code)

							# Assign back to parent
							d$values <- temp_vals

							df <- as.data.frame(d)
							names(df) <- gsub("\\.", "_", names(df))

						} else {
							# print("NO VALUES META")
							# Set values to null in case it exists but without `item` labels
							d$values <- NULL

							df <- as.data.frame(d)
						}

						df[, setdiff(cols, names(df))] <- NA
						return(df)
					}

					dts <- lapply(raw$variables, makeDf)
				}
			}

			temp <- Filter(is.data.frame, dts)
			dt <- do.call(rbind, temp)

			# Clean up row names aka variable names
			dt <- cbind(name = row.names(dt), dt)
			row.names(dt) <- NULL
			# If there are periods in the name field from concatenated numbers, remove
			dt$name <- gsub("\\..*", "", dt$name)
			dt[] <- lapply(dt, as.character)


		} else if (type %in% c("geographies", "geography")) {
			u <- paste(apiurl, "geography.json", sep="/")
			req <- httr::GET(u)
			# Check the API call for a valid response
			apiCheck(req)

			# If check didn't fail, parse the content
			raw <- apiParse(req)
			dt <- raw$fips
		} else if (type %in% c("groups")) {
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
			if (length(raw$values) == 0 | !("item" %in% names(raw$values))) {
				stop(paste("Value labels are not available for the selected variable:", variable_name))
			}
			dt <- utils::stack(raw$values$item)
			colnames(dt) <- c("label", "code")
			dt <- dt[, c("code", "label")]

		}	else {
			stop(paste('For "type", you entered: "', type, '". Did you mean "variables", "geographies", "groups", or "values"?', sep = ""))
		}
		return(dt)
	}

