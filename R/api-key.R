#' Retrieve a Census API key stored the .Renivron file
#'
#' @family helpers
#' @returns A CENSUS_KEY or CENSUS_API_KEY string stored in the user's .Renviron.
#'   file, or a warning message printed once per R session if none is found.
#'
#' @examples
#' \dontrun{
#' get_api_key()
#' }
#'
#' @export
get_api_key <- function() {
	if (Sys.getenv("CENSUS_KEY") != "") {
		key <- Sys.getenv("CENSUS_KEY")
		key
	} else if (Sys.getenv("CENSUS_API_KEY") != "") {
		key <- Sys.getenv("CENSUS_API_KEY")
		key
	} else {
		rlang::warn("You do not have a stored Census API key.\nRegister for an API key at https://api.census.gov/data/key_signup.html\nand store it in your Renviron file as CENSUS_KEY or CENSUS_API_KEY.\nLearn more at https://www.hrecht.com/censusapi/articles/getting-started.html.",
								.frequency = "once", .frequency_id = "api_key")
		key <- NULL
		key
	}
}
#' Is there a saved Census API key in the .Renivron file?
#'
#' @family helpers
#' @returns TRUE or FALSE.
#' @examples
#' has_api_key()
#'
#' @export
has_api_key <- function() {
	if (!is.null(get_api_key())) {
		TRUE
	} else {
		FALSE
	}
}

# Enforce using an API key
#'
#' @param key an API key
#' @returns an API key from a provided value or .Renviron
#'
#' @noRd

enforce_key <- function(key) {
	# If the `key` argument in the function isn't used then check the .Renviron
	if (is.null(key)) {
		key <- get_api_key()

		# If no key found, stop and throw a message
		if (is.null(key)) {
			stop("The U.S. Census Bureau requires an API key to access data.\nRegister for an API key at https://api.census.gov/data/key_signup.html\nand store it in your Renviron file as CENSUS_KEY or CENSUS_API_KEY,\nor use the `key` argument. Learn more at\nhttps://www.hrecht.com/censusapi/articles/getting-started.html.")
		}
	}

	# Return the specified or .Renviron key for use in the function
	return(key)
}
