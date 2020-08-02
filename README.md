# censusapi

[![Build Status](https://travis-ci.org/hrecht/censusapi.svg?branch=master)](https://travis-ci.org/hrecht/censusapi) [![CRAN Badge](https://www.r-pkg.org/badges/version/censusapi)](https://cran.r-project.org/package=censusapi)

`censusapi` is an accessor for the United States Census Bureau's [APIs](https://www.census.gov/developers/). More than [300 Census API endpoints](https://api.census.gov/data.html) are available, including Decennial Census, American Community Survey, Poverty Statistics, and Population Estimates APIs. This package is designed to let you get data from all of those APIs using the same main function—`getCensus`—and the same syntax for each dataset.

`censusapi` generally uses the APIs' original parameter names so that users can easily transition between Census's documentation and examples and this package. It also includes metadata functions to return data frames of available APIs, variables, and geographies.


## Installation
Get the latest stable release from CRAN: 
```R
install.packages("censusapi")
```

You can also install the latest development version of `censusapi` from Github using `devtools`. Most people will not want to do this - BEWARE!:
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

Get uninsured rates from the Small Area Health Insurance Estimates [(SAHIE) timeseries API](https://www.census.gov/data/developers/data-sets/Health-Insurance-Statistics.html) using `getCensus()`.

State-level data by income group within Alabama.
```R 
getCensus(name = "timeseries/healthins/sahie",
	vars = c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT"), 
	region = "state:01",
	time = 2017)
#>   time state    NAME IPRCAT                IPR_DESC PCTUI_PT
#> 1 2017    01 Alabama      0             All Incomes     11.0
#> 2 2017    01 Alabama      1      <= 200% of Poverty     18.3
#> 3 2017    01 Alabama      2      <= 250% of Poverty     17.3
#> 4 2017    01 Alabama      3      <= 138% of Poverty     19.4
#> 5 2017    01 Alabama      4      <= 400% of Poverty     14.5
#> 6 2017    01 Alabama      5 138% to 400% of Poverty     11.5
```
County-level data within Alabama, specified by adding the `regionin` parameter.
```R
sahie_counties <- getCensus(name = "timeseries/healthins/sahie",
	vars = c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT"), 
	region = "county:*",
	regionin = "state:01",
	time = 2017)
head(sahie_counties, n=12L)
#>    time state county                NAME IPRCAT    IPR_DESC PCTUI_PT
#> 1  2017    01    003  Baldwin County, AL      0 All Incomes     11.3
#> 2  2017    01    001  Autauga County, AL      0 All Incomes      8.7
#> 3  2017    01    015  Calhoun County, AL      0 All Incomes     11.9
#> 4  2017    01    005  Barbour County, AL      0 All Incomes     12.2
#> 5  2017    01    007     Bibb County, AL      0 All Incomes     10.2
#> 6  2017    01    009   Blount County, AL      0 All Incomes     13.4
#> 7  2017    01    011  Bullock County, AL      0 All Incomes     11.4
#> 8  2017    01    013   Butler County, AL      0 All Incomes     11.2
#> 9  2017    01    027     Clay County, AL      0 All Incomes     13.9
#> 10 2017    01    017 Chambers County, AL      0 All Incomes     11.9
#> 11 2017    01    019 Cherokee County, AL      0 All Incomes     11.2
#> 12 2017    01    021  Chilton County, AL      0 All Incomes     13.8
```
Retrieve annual data using the `time` argument by specifying a start year and stop year.
```R
sahie_annual <- getCensus(name = "timeseries/healthins/sahie",
    vars = c("NAME", "PCTUI_PT"),
    region = "state:01",
    time = "from 2006 to 2017")
sahie_annual
#> 		time state    NAME PCTUI_PT
#> 1  2006    01 Alabama     15.7
#> 2  2007    01 Alabama     14.6
#> 3  2008    01 Alabama     15.3
#> 4  2009    01 Alabama     15.8
#> 5  2010    01 Alabama     16.9
#> 6  2011    01 Alabama     16.6
#> 7  2012    01 Alabama     15.8
#> 8  2013    01 Alabama     15.9
#> 9  2014    01 Alabama     14.2
#> 10 2015    01 Alabama     11.9
#> 11 2016    01 Alabama     10.8
#> 12 2017    01 Alabama     11.0
```

Get the uninsured rate for non-elderly adults (`AGECAT = 1`) with incomes of 138 to 400% of the poverty line (`IPRCAT = 5`), by race (`RACECAT`) and state.
```R
sahie_nonelderly <- getCensus(name = "timeseries/healthins/sahie",
	vars = c("NAME", "PCTUI_PT", "IPR_DESC", "AGE_DESC", "RACECAT", "RACE_DESC"), 
	region = "state:*", 
	time = 2017,
	IPRCAT = 5,
	AGECAT = 1)
head(sahie_nonelderly)
#>   time state       NAME PCTUI_PT                IPR_DESC       AGE_DESC RACECAT RACE_DESC IPRCAT AGECAT
#> 1 2017    01    Alabama     14.6 138% to 400% of Poverty 18 to 64 years       0 All Races      5      1
#> 2 2017    02     Alaska     24.3 138% to 400% of Poverty 18 to 64 years       0 All Races      5      1
#> 3 2017    04    Arizona     16.6 138% to 400% of Poverty 18 to 64 years       0 All Races      5      1
#> 4 2017    05   Arkansas     12.4 138% to 400% of Poverty 18 to 64 years       0 All Races      5      1
#> 5 2017    06 California     13.6 138% to 400% of Poverty 18 to 64 years       0 All Races      5      1
#> 6 2017    08   Colorado     14.6 138% to 400% of Poverty 18 to 64 years       0 All Races      5      1
```

Read more on how to build a `censusapi` call in [Getting started with censusapi](https://hrecht.github.io/censusapi/articles/getting-started.html) and see examples from every API in the [example master list](https://hrecht.github.io/censusapi/articles/example-masterlist.html).

## Disclaimer
This product uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
