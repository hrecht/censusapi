#' Internal function: Get the API response, return a data frame
#'
#' @keywords internal
getFunction <- function(apiurl, name, key, get, region, regionin, time, show_call, convert_variables, year, date, period, monthly, category_code, data_type_code, naics, pscode, naics2012, naics2007, naics2002, naics1997, sic, ...) {

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

		# Make all columns character - they already are from the Census but just in
		# case the Census does wonky things
		df[] <- lapply(df, as.character)

		if (convert_variables == TRUE) {
			# If these are part of the variable name, keep as string
			string_col_parts_list <- c("_TTL", "_NAME", "NAICS", "FAGE4", "LABEL",
																 "_DESC", "CAT", "UNIT_QY", "_FLAG",
																 "DISTRICT", "EMPSZES", "POPGROUP")

			# Collapse into a | delimited string for grepl
			collapse_col_parts <- function(parts) {
				collapsed <- paste0(parts, collapse = "|")
				return(collapsed)
			}
			common_string_cols <- collapse_col_parts(string_col_parts_list)

			# Geography variables - exact matches only
			geos_list <- c("GEO_ID", "GEOID", "GEOID1", "GEOID2", "GEOCOMP",
										 "SUMLEVEL", "GEOTYPE",  "GEONAME", "GEOVARIANT",

										 # Top-level geographies
										 "NATION", "US", "DIVISION", "REGION", "LSAD_NAME",

										 # Summary levels - but not ACS Flows SUMLEV1 and SUMLEV2 ints
										 "SUMLEVEL", "SUMMARY_LVL",

										 # States
										 "STATE", "ST", "STNAME", "STATE_OR_PART",

										 # Counties
										 "COUNTY",  "CTY_CODE", "CTY_NAME", "CTYNAME", "EEOCOUNTY",
										 "COUSUB", "COUNTY1", "COUNTY2", "COUNTY_OR_PART",
										 "COUNTY_SUBDIVISION", "COUNTY_SUBDIVISION_OR_PART",
										 "COUNTYSET",

										 # Tracts
										 "TRACT", "TRACT_OR_PART",

										 # Places and cities
										 "PLACE", "PLACEREM", "CONCITY", "CONSCITY", "PRINCITY", "SUBMCD",
										 "PRINCIPAL_CITY_OR_PART", "PRINCIPAL_CITY", "PLACE_REMAINDER_OR_PART",
										 "PLACE_OR_PART", "CONSOLIDATED_CITY", "CONSOLIDATED_CITY_OR_PART",
										 "PLACE_BALANCE_OR_PART", "PLACE_REMAINDER",

										 # PUMAs
										 "PUMA", "PUMA5", "MIGPUMA", "POWPUMA",
										 "PUBLIC_USE_MICRODATA_AREA",

										 # Blocks
										 "BH", "BLKGRP", "BLOCK", "BLOCK_GROUP", "GIDBG",
										 "BLOCK_GROUP_OR_PART",

										 # AIAN geographies
										 "AIANHH", "AIARO", "AIHHTL", "AIRES", "ANRC", "TTRACT",
										 "TBLKGRP", "TRIBALBG", "TRIBALCT", "TRIBALSUB", "TRISUBREM",
										 "AMERICAN_INDIAN_AREA_ALASKA_NATIVE_AREA_HAWAIIAN_HOME_LAND",
										 "ALASKA_NATIVE_REGIONAL_CORPORATION",
										 "AMERICAN_INDIAN_AREA_ALASKA_NATIVE_AREA_HAWAIIAN_HOME_LAND_OR_PART",
										 "TRIBAL_SUBDIVISION_REMAINDER_OR_PART", "TRIBAL_CENSUS_TRACT_OR_PART",
										 "AMERICAN_INDIAN_AREA_ALASKA_NATIVE_AREA_RESERVATION_OR_STATISTICAL_ENTITY_ONLY",
										 "AMERICAN_INDIAN_AREA_OFF_RESERVATION_TRUST_LAND_ONLY_HAWAIIAN_HOME_LAND",
										 "TRIBAL_CENSUS_TRACT",
										 "AMERICAN_INDIAN_AREA_OFF_RESERVATION_TRUST_LAND_ONLY_HAWAIIAN_HOME_LAND_OR_PART",
										 "AMERICAN_INDIAN_AREA_ALASKA_NATIVE_AREA_RESERVATION_OR_STATISTICAL_ENTITY_ONLY_OR_PART",
										 "AMERICAN_INDIAN_TRIBAL_SUBDIVISION",
										 "TRIBAL_BLOCK_GROUP_OR_PART", "TRIBAL_SUBDIVISION_REMAINDER",
										 "AMERICAN_INDIAN_TRIBAL_SUBDIVISION_OR_PART",
										 "TRIBAL_BLOCK_GROUP",
										 "ALASKA_NATIVE_REGIONAL_CORPORATION_OR_PART",

										 # Metro areas
										 "CSA", "MSA", "CBSA", "METDIV", "MSACMSA",
										 "METROPOLITAN_DIVISION",
										 "METROPOLITAN_STATISTICAL_AREA_MICROPOLITAN_STATISTICAL_AREA",
										 "COMBINED_STATISTICAL_AREA",
										 "METROPOLITAN_STATISTICAL_AREA_MICROPOLITAN_STATISTICAL_AREA_OR_PART",
										 "COMBINED_STATISTICAL_AREA_OR_PART",
										 "METROPOLITAN_DIVISION_OR_PART",
										 "CONSOLIDATED_METROPOLITAN_STATISTICAL_AREA",
										 "PRIMARY_METROPOLITAN_STATISTICAL_AREA",
										 "CONSOLIDATED_METROPOLITAN_STATISTICAL_AREA_OR_PART",
										 "PRIMARY_METROPOLITAN_STATISTICAL_AREA_OR_PART",
										 "METROPOLITAN_STATISTICAL_AREAS",
										 "MICROPOLITAN_STATISTICAL_AREA",

										 # Congressional districts
										 "CD", "CD106", "CD107", "CD108", "CD109", "CD110", "CD111",
										 "CD112", "CD113", "CD114", "CD115", "CD116", "CDCURR",
										 "CONGRESSIONAL_DISTRICT", "CONGRESSIONAL_DISTRICT_OR_PART",
										 # Future proof congress for a while
										 "CD117", "CD118", "CD119",

										 # State legislative districts
										 "SLDL", "SLDU", "STATE_LEGISLATIVE_DISTRICT_LOWER_CHAMBER",
										 "STATE_LEGISLATIVE_DISTRICT_UPPER_CHAMBER",
										 "STATE_LEGISLATIVE_DISTRICT_LOWER_CHAMBER_OR_PART",
										 "STATE_LEGISLATIVE_DISTRICT_UPPER_CHAMBER_OR_PART",

										 # NECTAs and related
										 "CNECTA", "NECTA", "NECTADIV", "NECMA", "NECTA_DIVISION",
										 "NEW_ENGLAND_CITY_AND_TOWN_AREA",
										 "COMBINED_NEW_ENGLAND_CITY_AND_TOWN_AREA",
										 "NEW_ENGLAND_CITY_AND_TOWN_AREA_OR_PART",
										 "COMBINED_NEW_ENGLAND_CITY_AND_TOWN_AREA_OR_PART",
										 "NECTA_DIVISION_OR_PART",
										 "NEW_ENGLAND_COUNTY_METROPOLITAN_AREA",
										 "NEW_ENGLAND_COUNTY_METROPOLITAN_AREA_OR_PART",

										 # School districts
										 "SDELM", "SDSEC", "SDUNI", "SCHOOL_DISTRICT_ELEMENTARY",
										 "SCHOOL_DISTRICT_SECONDARY", "SCHOOL_DISTRICT_UNIFIED",
										 "SCHOOL_DISTRICT_ELEMENTARY_OR_PART",
										 "SCHOOL_DISTRICT_SECONDARY_OR_PART",
										 "SCHOOL_DISTRICT_UNIFIED_OR_PART",
										 "SCHOOL_DISTRICT_ADMINISTRATIVE_AREA",

										 # Sub-Minor Civil Division
										 "SUBMCD", "SUBMINOR_CIVIL_DIVISION",
										 "SUBMINOR_CIVIL_DIVISION_OR_PART",

										 # ZCTAs
										 "ZIPCODE", "ZCTA", "ZCTA5", "ZCTA3", "ZIP_CODE",
										 "ZIP_CODE_TABULATION_AREA",
										 "ZIP_CODE_TABULATION_AREA_OR_PART",
										 "ZIP_CODE_TABULATION_AREA_3_DIGIT",
										 "ZIP_CODE_TABULATION_AREA_3_DIGIT_OR_PART",

										 # Urban area, Urban/rural
										 "UA", "UR", "URBAN_AREA", "URBAN_RURAL", "URBAN_AREA_OR_PART",

										 # Voting district
										 "VTD", "VOTING_DISTRICT",
										 "VOTING_DISTRICT_OR_PART",

										 # Imports and exports geographies
										 "USITC", "USITCHISTORY", "USITCREG", "CUSTDISTRICT", "DIST_NAME",
										 "PORT", "WORLD",
										 "USITC_STANDARD_COUNTRIES_AND_AREAS",
										 "USITC_STANDARD_INTERNATIONAL_REGIONS",
										 "USITC_STANDARD_HISTORICAL_COUNTRIES_AND_AREAS",

										 # Various Economic APIs geographies
										 "CFSAREA", "COMMREG", "ECPLACE",
										 "CFS_AREA_OR_PART", "COMMERCIAL_REGION",

										 # 2020 Decennial
										 "ESTATE",

										 # Random rarely-used geographies
										 "ESTPLACE", "EUCOUSUB", "EUPB", "GENC",
										 "WORKFORCE_INVESTMENT_AREA",
										 "GENC_STANDARD_COUNTRIES_AND_AREAS",
										 "PUERTO_RICO_PLANNING_AREA",

										 # CPS microdata
										 "GESTFIPS", "GTCO", "HG_FIPS",

										 # SIPP microdata
										 "TFIPSST")

			# Microdata APIs - don't convert string identifier variables that appear
			# in >5 endpoints as strings only or nearly always as strings
			if (grepl("cps/|pums|sipp", name, ignore.case = T)) {

				common_string_cols <- collapse_col_parts(
					c( #SIPP PUMS
						"SSUID",
						# CPS PUMS
						"HRHHID", "HRSAMPLE", "HRSERSUF", "GECMSASZ", "H_ID", "H_ID_PL",
						"H_IDNUM", "OCCURNUM", "QSTNUM",
						# ACS PUMS
						"RT", "SERIALNO", "CONCAT_ID", "RECORD_TYPE", "SOCP",
						"OCCP10", "OCCP02", "OCCP12",
					common_string_cols))
			}

			# For ACS data, also keep as strings ACS annotation variables
			# ending in MA or EA or SS
			if (grepl("acs/acs", name, ignore.case = T) &
					!(grepl("pums", name, ignore.case = T))) {
				common_string_cols <- collapse_col_parts(
					c("MA", "EA", "SS",
						common_string_cols))
			}

			# Columns that contain string parts in the name stay as strings
			string_part_cols <- grep(common_string_cols, names(df), value = TRUE, ignore.case = T)

			# Columns that match geos_list exactly stay as strings (other than case sensitivity)
			geo_cols <- names(df)[toupper(names(df)) %in% geos_list]

			# Identify all the geo/string columns to keep as strings
			string_cols <- c(geo_cols, string_part_cols)

			# For columns that aren't explicitly defined here as strings, convert them to numeric
			# If they are actually all numbers
			for(col in setdiff(names(df), string_cols)) {
				df[,col] <- utils::type.convert(df[,col],
																				as.is = TRUE,
																				# Some returned data contains messy NAs, account for them
																				na.strings = c(NA, "NULL", "N/A", "NA"))
				#}

			}
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
#' @param name The programmatic name of your dataset, e.g.
#'   "timeseries/poverty/saipe" or "acs/acs5". Use listCensusApis() to see valid
#'   dataset names. Required.
#' @param vintage Vintage (year) of dataset, e.g. 2014. Not required for
#'   timeseries APIs.
#' @param vars List of variables to get. Required.
#' @param region Geography to get.
#' @param regionin Optional hierarchical geography to limit region.
#' @param key A Census API key, obtained at
#'   <https://api.census.gov/data/key_signup.html>. If you have a `CENSUS_KEY` or
#'   `CENSUS_API_KEY` stored in your .Renviron file, getCensus() will
#'   automatically use that key. Using a key is recommended but not required.
#' @param time Time period of data to get. Required for most timeseries APIs.
#' @param show_call Display the underlying API call that was sent to the Census
#'   Bureau. Default is FALSE.
#' @param convert_variables Convert columns that are likely numbers into numeric
#'   data. Default is TRUE. If false, all columns will be characters, which is
#'   the type returned by the Census Bureau.
#' @param
#' year,date,period,monthly,category_code,data_type_code,naics,pscode,naics2012,naics2007,naics2002,naics1997,sic
#' Optional arguments used in some timeseries data APIs.
#' @param ... Other valid arguments to pass to the Census API. Note: the APIs
#'   are case sensitive.
#' @returns A data frame with results from the specified U.S. Census Bureau dataset.
#' @examplesIf has_api_key()
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
					 show_call = FALSE,
					 convert_variables = TRUE,
					 year = NULL,
					 date = NULL,
					 period = NULL,
					 monthly = NULL,
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
		key <- get_api_key()
	}
	apiurl <- constructURL(name, vintage)

	# Census API max vars per call = 50
	# Splitting function based on work by Nicholas Nagle, https://rpubs.com/nnnagle/19337
	if(length(vars)>50){
		# Split vars into list
		vars <- split(vars, ceiling(seq_along(vars)/50))
		get <- lapply(vars, function(x) paste(x, sep='', collapse=","))
		data <- lapply(get, function(x) getFunction(apiurl, name, key, x, region, regionin, time, show_call, convert_variables, year, date, period, monthly, category_code, data_type_code, naics, pscode, naics2012, naics2007, naics2002, naics1997, sic, ...))

		data <- Reduce(function(x, y) merge(x, y, all = TRUE, sort = FALSE), data)

	} else {
		get <- paste(vars, sep='', collapse=',')
		data <- getFunction(apiurl, name, key, get, region, regionin, time, show_call, convert_variables, year, date, period, monthly, category_code, data_type_code, naics, pscode, naics2012, naics2007, naics2002, naics1997, sic, ...)
	}

	# If there are any duplicate columns (ie if you put a variable in vars twice) remove the duplicates
	data <- data[, !duplicated(colnames(data))]

	# Reorder columns so that lowercase column names (geographies) are first
	data <- data[,c(which(grepl("[a-z]", colnames(data))), which(!grepl("[a-z]", colnames(data))))]
	return(data)
}
