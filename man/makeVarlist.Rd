% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/makevar_functions.R
\name{makeVarlist}
\alias{makeVarlist}
\title{Use variable metadata to find variables containing a given string}
\usage{
makeVarlist(name, vintage = NULL, find, varsearch = "all", output = "list")
}
\arguments{
\item{name}{API programmatic name - e.g. acs/acs5. Use \code{listCensusApis()} to
see valid dataset names.}

\item{vintage}{Vintage (year) of dataset. Not required for timeseries APIs.}

\item{find}{A string to find in the variable metadata.}

\item{varsearch}{Optional argument specifying which fields to search. Default
is "all". Options are "all", "name", "label", or "concept".}

\item{output}{Optional argument, specifying output to "list" or "dataframe".
Default is "list".}
}
\value{
A data frame containing variable metadata
}
\description{
Return a list of variable names or data frame of variable metadata containing
a given string. This can be used create a list of variables to later pass to
getCensus, or a data frame documenting variables used in a given project.
}
\examples{
\dontshow{if (has_api_key()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# Return a list, and then use getCensus function to retrieve those variables
myvars <- makeVarlist(name = "timeseries/poverty/saipe",
  find = "Ages 0-4",
  varsearch = "label")
myvars
saipe_dt <- getCensus(name = "timeseries/poverty/saipe",
  time = 2016,
  vars = myvars,
  region = "state:*")
head(saipe_dt)
\dontshow{\}) # examplesIf}
}
\seealso{
Other metadata: 
\code{\link{listCensusApis}()},
\code{\link{listCensusMetadata}()}
}
\concept{metadata}
