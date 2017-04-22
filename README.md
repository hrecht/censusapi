# censusapi

[![Build Status](https://travis-ci.org/hrecht/censusapi.svg?branch=master)](https://travis-ci.org/hrecht/censusapi)

This package is an accessor for the United States Census Bureau's [APIs](https://www.census.gov/developers/). As of 2017 these include Decennial Census, American Community Survey, Poverty Statistics, and Population Estimates APIs - among many others. censusapi is designed to use the APIs' original parameter names so that users can easily transition between Census's documentation and examples and this package. It also includes functions using the [dataset discovery service](http://www.census.gov/data/developers/updates/new-discovery-tool.html) to return dataset metadata, geographies, and variables as data frames.

For more info and examples, see presentation [slides](http://urbaninstitute.github.io/R-Trainings/accesing-census-apis/presentation/index.html#/) and [code](https://github.com/UrbanInstitute/R-Trainings/blob/gh-pages/accesing-census-apis/accessingCensusApis.R) from Urban Institute R Users Group presentation, March 2016

## Installation

Install the package using devtools:
```R
# install.packages("devtools")
devtools::install_github("hrecht/censusapi")
```

## API key setup
To use the Census APIs, [sign up](http://api.census.gov/data/key_signup.html) for an API key, which will be sent to your provided email address. You'll need that key to use this package. While Census currently does not require an API key for all APIs, that can change at any moment and so this package enforces key usage.

A recommended way to manage your key is to add it to you .Renviron file. Most users will want to do this.
Within R, run:
```R
# Add key to .Renviron
Sys.setenv(CENSUS_KEY=YOURKEYHERE)
# Reload .Renviron
readRenviron("~/.Renviron")
# Check to see that the expected key is output in your R console
Sys.getenv("CENSUS_KEY")
```
Or, open your .Renviron file in a text editor and add the following line:
`CENSUS_KEY=YOURKEYHERE`

Once you've added your census key to your system environment, censusapi will use it by default without any extra work on your part. 

In some instances you might not want to put your key in your .Renviron - for example, if you're on a shared school computer. You can always choose to manually set `key="YOURKEY` as an argument in getCensus if you prefer.

## Usage examples
```R
library(censusapi)
# Decennial Census sf3, 1990
data1990 <- getCensus(name="sf3", vintage=1990, 
	vars=c("P0070001", "P0070002", "P114A001"), 
	region="county:*")

# 5 year ACS, 2014 - using regionin argument to get data within a state
data2014 <- getCensus(name="acs5", vintage=2014,
	vars=c("NAME", "B01001_001E", "B19013_001E", "B17010_017E", "B17010_037E"), 
	region="congressional district:*", regionin="state:36")

# SAHIE time series API, 2011
sahie <- getCensus(name="timeseries/healthins/sahie",
	vars=c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT", "RACECAT", "RACE_DESC"), 
	region="state:*", time=2011)
```

## Time series note
While the APIs generally return specific error messages for invalid variables or geographies, they currently return no content (status 204) without an error message when an invalid year is specified in some time series. If you're getting repeated 204 responses double check the Census documentation to make sure your time period is valid.
