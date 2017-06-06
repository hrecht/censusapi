# censusapi

[![Build Status](https://travis-ci.org/hrecht/censusapi.svg?branch=master)](https://travis-ci.org/hrecht/censusapi) [!CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/censusapi)

`censusapi` is an accessor for the United States Census Bureau's [APIs](https://www.census.gov/developers/). As of 2017 [over 200 Census API endpoints](https://api.census.gov/data.html) are available, including Decennial Census, American Community Survey, Poverty Statistics, and Population Estimates APIs. This package is designed to let you get data from all of those APIs using the same main function—`getCensus`—and the same syntax for each dataset.

`censusapi` generally uses the APIs' original parameter names so that users can easily transition between Census's documentation and examples and this package. It also includes metadata functions to return data frames of available APIs, variables, and geographies.

For more details, see [Getting started with censusapi](https://hrecht.github.io/censusapi/articles/getting-started.html) and the package's [website](https://hrecht.github.io/censusapi/index.html).

## Installation
Get the latest stable release from CRAN: `install.packages("censusapi")`

Install the latest development version of `censusapi` from Github using `devtools`:
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

In some instances you might not want to put your key in your .Renviron - for example, if you're on a shared school computer. You can always choose to manually set `key="YOURKEY"` as an argument in getCensus if you prefer.

## Usage examples
```R
library(censusapi)
```

Get uninsured rates in Alabama by income group from the Small Area Health Insurance Estimates [(SAHIE) timeseries API](https://www.census.gov/data/developers/data-sets/Health-Insurance-Statistics.html)

```R 
# State-level data for Alabama
getCensus(name="timeseries/healthins/sahie",
	vars=c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT"), 
	region="state:1", time=2015)
#>      NAME IPRCAT                IPR_DESC PCTUI_PT time state
#> 1 Alabama      0             All Incomes     11.9 2015    01
#> 2 Alabama      1      <= 200% of Poverty     19.8 2015    01
#> 3 Alabama      2      <= 250% of Poverty     18.6 2015    01
#> 4 Alabama      3      <= 138% of Poverty     21.2 2015    01
#> 5 Alabama      4      <= 400% of Poverty     15.5 2015    01
#> 6 Alabama      5 138% to 400% of Poverty     11.8 2015    01

# County-level data within Alabama, specified by adding the `regionin` parameter.
sahie_counties <- getCensus(name="timeseries/healthins/sahie",
	vars=c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT"), 
	region="county:*", regionin="state:1", time=2015)
head(sahie_counties, n=12L)
#>                  NAME IPRCAT                IPR_DESC PCTUI_PT time state county
#> 1  Autauga County, AL      0             All Incomes      9.4 2015    01    001
#> 2  Autauga County, AL      1      <= 200% of Poverty     16.8 2015    01    001
#> 3  Autauga County, AL      2      <= 250% of Poverty     15.5 2015    01    001
#> 4  Autauga County, AL      3      <= 138% of Poverty     18.6 2015    01    001
#> 5  Autauga County, AL      4      <= 400% of Poverty     12.4 2015    01    001
#> 6  Autauga County, AL      5 138% to 400% of Poverty      9.6 2015    01    001
#> 7  Baldwin County, AL      0             All Incomes     11.5 2015    01    003
#> 8  Baldwin County, AL      1      <= 200% of Poverty     21.1 2015    01    003
#> 9  Baldwin County, AL      2      <= 250% of Poverty     19.5 2015    01    003
#> 10 Baldwin County, AL      3      <= 138% of Poverty     22.5 2015    01    003
#> 11 Baldwin County, AL      4      <= 400% of Poverty     15.7 2015    01    003
#> 12 Baldwin County, AL      5 138% to 400% of Poverty     12.2 2015    01    003

```

See more examples in [Getting started with censusapi](https://hrecht.github.io/censusapi/articles/getting-started.html)

## Time series note
While the APIs generally return specific error messages for invalid variables or geographies, they currently return no content (status 204) without an error message when an invalid year is specified in some time series. If you're getting repeated 204 responses double check the Census documentation to make sure your time period is valid.

## Disclaimer
This product uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau.
