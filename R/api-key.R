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
		rlang::warn("You do not have a stored Census API key. Using a key is recommended but not required.\nThe Census Bureau may limit your daily requests.\nRegister for an API key at https://api.census.gov/data/key_signup.html\nand store it in your Renviron file as CENSUS_KEY or CENSUS_API_KEY.\nLearn more at https://www.hrecht.com/censusapi/articles/getting-started.html.",
								.frequency = "once", .frequency_id = "api_key")
		key <- NULL
		key
	}
}
#' Is there a saved API token?
#'
#' @family helpers
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
