# censusapi

Retrieve data from any [Census API](http://www.census.gov/data/developers/data-sets.html), as well as metadata about the [available datasets](http://api.census.gov/data.html) and each API's [variables](http://api.census.gov/data/2000/sf1/variables.html) and [geographies](http://api.census.gov/data/2000/sf1/geography.html).

For more info and examples, see presentation [slides](http://urbaninstitute.github.io/R-Trainings/accesing-census-apis/presentation/index.html#/) and [code](https://github.com/UrbanInstitute/R-Trainings/blob/gh-pages/accesing-census-apis/accessingCensusApis.R) from Urban Institute R Users Group presentation, March 2016

## API key setup
To use the Census APIs, [sign up](http://api.census.gov/data/key_signup.html) for an API key, which will be sent to your provided email address.
If you'll be sharing your code, make sure not to paste that code into your R script. One better way to access the key is to save it as a .txt or other text file on your system.
```R
# install.packages("readr")
library(readr)
censuskey <- read_file("path/to/censuskey.txt")
```

## Installation

```R
# install.packages("devtools")
devtools::install_github("hrecht/censusapi")
```

## Why?
There are a few other packages dealing with the Census APIs, but so far they all specialize in only some of the available APIs (e.g. ACS, decennial). This package is dataset agnostic. It also includes functions using the [dataset discovery service](http://www.census.gov/data/developers/updates/new-discovery-tool.html) to return dataset metadata, geographies, and variables as data frames.

## Usage examples
```R
library(censusapi)
# Decennial Census sf3, 1990
data1990 <- getCensus(name="sf3", vintage=1990, key=censuskey, 
	vars=c("P0070001", "P0070002", "P114A001"), 
	region="county:*")

# 5 year ACS, 2014 - using regionin argument to get data within a state
data2014 <- getCensus(name="acs5", vintage=2014, key=censuskey, 
	vars=c("NAME", "B01001_001E", "B19013_001E", "B17010_017E", "B17010_037E"), 
	region="congressional district:*", regionin="state:36")

# SAHIE time series API, 2011
sahie <- getCensus(name="timeseries/healthins/sahie", key=censuskey, 
	vars=c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT", "RACECAT", "RACE_DESC"), 
	region="state:*", time=2011)
```

## Time series
Time series API arguments vary by API and are still being added to the package and tested. Feel free to submit an issue or pull request if your API isn't yet handled.
Note: while the APIs generally return specific error messages for invalid variables or geographies, they currently return no content (status 204) without an error message when an invalid year is specified in some time series. If you're getting repeated 204 responses double check the Census documentation to make sure your time period is valid.
