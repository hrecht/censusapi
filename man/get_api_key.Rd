% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api-key.R
\name{get_api_key}
\alias{get_api_key}
\title{Retrieve a Census API key stored the .Renivron file}
\usage{
get_api_key()
}
\value{
A CENSUS_KEY or CENSUS_API_KEY string stored in the user's .Renviron.
file, or a warning message printed once per R session if none is found.
}
\description{
Retrieve a Census API key stored the .Renivron file
}
\examples{
\dontrun{
get_api_key()
}

}
\seealso{
Other helpers: 
\code{\link{has_api_key}()}
}
\concept{helpers}
