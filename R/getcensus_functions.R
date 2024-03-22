#' Internal function: Get the API response, return a data frame
#'
#' @param apiurl, key, get, region, time, etc
#' @keywords internal
#' @export
getFunction <- function(apiurl, name, key, get, region, regionin, time, year, date, period, monthly, show_call, convert_variables, category_code, data_type_code, naics, pscode, naics2012, naics2007, naics2002, naics1997, sic, ...) {

	# Return API's built in error message if invalid call
	apiCheck <- function(req) {
		if (req$status_code==400) {
			error_message <- (gsub("<[^>]*>", "", httr::content(req, as="text")))
			if (error_message == "error: missing 'for' argument") {
				stop("This dataset requires you to specify a geography with the 'region' argument.")
			}
			stop(paste("The Census Bureau returned the following error message:\n", error_message,
								 "\n Your API call was: ", print(req$url)))
		}
		# Some time series don't give error messages, just don't resolve (e.g. SAIPE)
		if (req$status_code==204) stop("204, no content was returned.\nSee ?listCensusMetadata to learn more about valid API options.", call. = FALSE)
		if (identical(httr::content(req, as = "text"), "")) stop(paste("No output to parse. \n Your API call was: ", print(req$url)), call. = FALSE)
	}

	apiParse <- function (req) {
		if (jsonlite::validate(httr::content(req, as="text"))[1] == FALSE) {
			error_message <- (gsub("<[^>]*>", "", httr::content(req, as="text")))
			stop(paste("The Census Bureau returned the following error message:\n", error_message, "\nYour api call was: ", req$url))
		} else {
			# Show call if option is true
			if (show_call == TRUE) {
				print(paste("Your successful api call was: ", req$url))
				print("For more information, visit the documentation at https://www.hrecht.com/censusapi/")
			}
			raw <- jsonlite::fromJSON(httr::content(req, as = "text"))
		}
	}

	# Function to clean up column names - particularly ones with periods in them
	cleanColnames <- function(dt) {
		# No trailing punct
		colnames(dt) <- gsub("\\.[[:punct:]]*$", "", colnames(dt))
		# All punctuation becomes underscore
		colnames(dt) <- gsub("[[:punct:]]", "_", colnames(dt))
		# Get rid of repeat underscores
		colnames(dt) <- gsub("(_)\\1+", "\\1", colnames(dt))
		return(dt)
	}

	responseFormat <- function(raw) {
		# Make first row the header
		colnames(raw) <- raw[1, ]
		df <- data.frame(raw)
		df <- df[-1,]
		df <- cleanColnames(df)
		# Make all columns character
		df[] <- lapply(df, as.character)

		# Make columns numeric based on column names - unfortunately best strategy without additional API calls given structure of data across endpoints
		if (convert_variables == TRUE) {
			string_col_parts <- "_TTL|_NAME|NAICS2012|NAICS2017|NAICS2012_TTL|NAICS2017_TTL|fage4|FAGE4|LABEL|_DESC|CAT"

			# For ACS data, do not make columns numeric if they are ACS annotation variables - ending in MA or EA or SS
			if (grepl("acs/acs", name, ignore.case = T)) {
				# Do not make known string/label variables numeric
				numeric_cols <- grep("[0-9]", names(df), value=TRUE)
				string_cols <- grep(paste0("MA|EA|SS|", string_col_parts), numeric_cols, value = TRUE, ignore.case = T)

				# Small Area Health Insurance Estimates
			} else if (grepl("healthins/sahie", name, ignore.case = T)) {
				numeric_cols <- grep("[0-9]|_PT|NIPR|PCTIC|PCTUI|NIC|NUI", names(df), value=TRUE, ignore.case = T)
				string_cols <- grep(string_col_parts, numeric_cols, value = TRUE, ignore.case = T)

				# Small Area Income and Poverty Estimates
			} else if (grepl("poverty/saipe", name, ignore.case = T)) {
				numeric_cols <- grep("[0-9]|SAEMHI|SAEPOV", names(df), value=TRUE, ignore.case = T)
				string_cols <- grep(string_col_parts, numeric_cols, value = TRUE, ignore.case = T)

				# Population and Housing Estimates
			} else if (grepl("pep/", name, ignore.case = T)) {
				numeric_cols <- grep("[0-9]|POP|DENSITY|HUEST", names(df), value=TRUE, ignore.case = T)
				string_cols <- grep(string_col_parts, numeric_cols, value = TRUE, ignore.case = T)

				# County Business Patterns
			} else if (name == "cbp" | name == "zbp") {
				# Exact matches for CBP variables
				numeric_cols <- grep("[0-9]|\\<EMP\\>|\\<ESTAB\\>|PAYANN", names(df), value=TRUE, ignore.case = T)
				string_cols <- grep(string_col_parts, numeric_cols, value = TRUE, ignore.case = T)

				# Decennial Response Rates
			} else if (name == "dec/responserate") {
				numeric_cols <- grep("[0-9]|CINT|MIN|MED|AVG|MAX|DRR|CRR", names(df), value=TRUE, ignore.case = T)
				string_cols <- grep(string_col_parts, numeric_cols, value = TRUE, ignore.case = T)

				# International trade
			} else if (grepl("timeseries/intltrade/", name, ignore.case = T)) {
				numeric_cols <- grep("[0-9]", names(df), value=TRUE, ignore.case = T)
				string_col_parts <- paste0(string_col_parts, "|UNIT_QY|_FLAG")
				string_cols <- grep(string_col_parts, numeric_cols, value = TRUE, ignore.case = T)

				# Household Pulse Survey
			} else if (name == "timeseries/hps") {
				numeric_cols <- grep("_RATE|_TOTAL|_UNIV|_MOE|WEEK", names(df), value=TRUE, ignore.case = T)
				string_cols <- grep(string_col_parts, numeric_cols, value = TRUE, ignore.case = T)

				# Microdata weighting variables
			} else if (grepl("cps/", name, ignore.case = T) |
								 name %in% c("acs/acs5/pums", "acs/acs5/pumspr", "acs/acs1/pums", "acs/acs1/pumspr")) {
				numeric_cols <- grep("[0-9]|PWSSWGT|HWHHWGT|PWFMWGT|PWLGWGT|PWCMPWGT
|PWORWGT|PWVETWGT|WGTP|PWGTP", names(df), value=TRUE, ignore.case = T)
				string_cols <- grep(string_col_parts, numeric_cols, value = TRUE, ignore.case = T)

			} else {
				# Do not make known string/label variables numeric
				numeric_cols <- grep("[0-9]", names(df), value=TRUE)
				string_cols <- grep(string_col_parts, numeric_cols, value = TRUE, ignore.case = T)
			}

			# Convert string "NULL" or "N/A" values to true NA
			df[(df == "NULL" | df == "N/A" | df == "NA")] <- NA

			for(col in setdiff(numeric_cols, string_cols)) df[,col] <- as.numeric(df[,col])
		}
		row.names(df) <- NULL

		return(df)
	}

	# Assemble call
	req <- httr::GET(apiurl, query = list(key = key, get = get, "for" = region, "in" = regionin, category_code = category_code, data_type_code = data_type_code, time = time, YEAR = year, DATE = date, PERIOD = period, MONTHLY = monthly, NAICS=naics, PSCODE=pscode, NAICS2012 = naics2012, NAICS2007 = naics2007, NAICS2002 = naics2002, NAICS1997 = naics1997, SIC = sic, ...))

	# Check the API call for a valid response
	apiCheck(req)

	# If check didn't fail, parse the content
	raw <- apiParse(req)

	# Format the response into a nice data frame
	df <- responseFormat(raw)
}

#' Retrieve Census data from a given API
#'
#' @param name The programmatic name of your dataset, e.g. `timeseries/poverty/saipe`
#' or `acs/acs5`. See `listCensusApis()` for options.
#' @param vintage Vintage (year) of dataset, e.g. 2014. Not required for timeseries APIs.
#' @param vars List of variables to get. Required.
#' @param region Geography to get.
#' @param regionin Optional hierarchical geography to limit region.
#' @param key A Census API key, obtained at https://api.census.gov/data/key_signup.html.
#' If you have a `CENSUS_KEY` or `CENSUS_API_KEY` stored in your .Renviron file, getCensus()
#' will automatically use that key. Using a key is recommended but not required.
#' @param time Time period of data to get, used with time series APIs.
#' @param show_call List the underlying API call that was sent to the Census Bureau.
#' @param convert_variables Convert likely numeric variables into numeric data.
#' Default is true. If false, results will be characters, which is the type returned by
#' the Census Bureau.
#' @param year,date,period,monthly,category_code,data_type_code,naics,pscode,naics2012,naics2007,naics2002,naics1997,sic
#' Optional arguments used in timeseries data APIs.
#' @param ... Other valid arguments to pass to the Census API. Note: the APIs are case sensitive.
#' @keywords api
#' @examples
#' \dontrun{
#' # Get total population and median household income for Census places
#' # (cities, towns, villages) in a single state from the 5-year American Community Survey.
#' acs_simple <- getCensus(
#'   name = "acs/acs5",
#'   vintage = 2022,
#'   vars = c("NAME", "B01001_001E", "B19013_001E"),
#'   region = "place:*",
#'   regionin = "state:01")
#' head(acs_simple)
#'
#' # Get all data from the B08301 variable group, "Means of Transportation to Work."
#' # This returns estimates as well as margins of error and annotation flags.
#' acs_group <- getCensus(
#'   name = "acs/acs5",
#'   vintage = 2022,
#'   vars = "group(B08301)",
#'   region = "state:*")
#' head(acs_group)
#'
#' # Retreive 2020 Decennial Census block group data within a specific Census tract,
#' # using the regionin argument to precisely specify the Census tract, county,
#' # and state.
#' decennial_block_group <- getCensus(
#' 	name = "dec/dhc",
#' 	vintage = 2020,
#' 	vars = c("NAME", "P1_001N"),
#' 	region = "block group:*",
#' 	regionin = "state:36+county:027+tract:220300")
#' head(decennial_block_group)
#'
#' # Get poverty rates for children and for people of all ages beginning in 2000 using the
#' # Small Area Income and Poverty Estimates API
#' saipe <- getCensus(
#'   name = "timeseries/poverty/saipe",
#'   vars = c("NAME", "SAEPOVRT0_17_PT", "SAEPOVRTALL_PT"),
#'   region = "state:01",
#'   time = "from 2000")
#' head(saipe)
#'
#' # Get the number of employees and number of establishments in the construction sector,
#' # NAICS2017 code 23, using the County Business Patterns API
#' cbp <- getCensus(
#' 	name = "cbp",
#' 	vintage = 2021,
#' 	vars = c("EMP", "ESTAB", "NAICS2017_LABEL"),
#' 	region = "county:*",
#' 	NAICS2017 = 23)
#' head(cbp)
#' }
#'
#' @export
getCensus <-
	function(name,
					 vintage = NULL,
					 key = NULL,
					 vars,
					 region = NULL,
					 regionin = NULL,
					 time = NULL,
					 year = NULL,
					 date = NULL,
					 period = NULL,
					 monthly = NULL,
					 show_call = FALSE,
					 convert_variables = TRUE,
					 category_code = NULL,
					 data_type_code = NULL,
					 naics = NULL,
					 pscode = NULL,
					 naics2012 = NULL,
					 naics2007 = NULL,
					 naics2002 = NULL,
					 naics1997 = NULL,
					 sic = NULL,
					 ...) {

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

	# Check for key in environment, print a message if one is not provided or in environment
	if (is.null(key)) {
		if (Sys.getenv("CENSUS_KEY") != "") {
			key <- Sys.getenv("CENSUS_KEY")
		} else if (Sys.getenv("CENSUS_API_KEY") != "") {
			key <- Sys.getenv("CENSUS_API_KEY")
		} else {
			message("You are not using a Census API key. Using a key is recommended but not required.\nThe Census Bureau may limit your daily requests.\nYou can register for an API key at https://api.census.gov/data/key_signup.html\nLearn more at https://www.hrecht.com/censusapi/articles/getting-started.html.")
		}
	}
	apiurl <- constructURL(name, vintage)

	# Census API max vars per call = 50
	# Splitting function based on work by Nicholas Nagle, https://rpubs.com/nnnagle/19337
	if(length(vars)>50){
		# Split vars into list
		vars <- split(vars, ceiling(seq_along(vars)/50))
		get <- lapply(vars, function(x) paste(x, sep='', collapse=","))
		data <- lapply(get, function(x) getFunction(apiurl, name, key, x, region, regionin, time, year, date, period, monthly, show_call, convert_variables, category_code, data_type_code, naics, pscode, naics2012, naics2007, naics2002, naics1997, sic, ...))

		data <- Reduce(function(x, y) merge(x, y, all = TRUE, sort = FALSE), data)

	} else {
		get <- paste(vars, sep='', collapse=',')
		data <- getFunction(apiurl, name, key, get, region, regionin, time, year, date, period, monthly, show_call, convert_variables, category_code, data_type_code, naics, pscode, naics2012, naics2007, naics2002, naics1997, sic, ...)
	}

	# If there are any duplicate columns (ie if you put a variable in vars twice) remove the duplicates
	data <- data[, !duplicated(colnames(data))]

	# Reorder columns so that lowercase column names (geographies) are first
	data <- data[,c(which(grepl("[a-z]", colnames(data))), which(!grepl("[a-z]", colnames(data))))]
	return(data)
}
