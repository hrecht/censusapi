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

A simple example: get state-level uninsured rates by income group in Alabama.
```R 
getCensus(name = "timeseries/healthins/sahie",
	vars = c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT"), 
	region = "state:01",
	year = 2018)
#>   state    NAME IPRCAT                IPR_DESC PCTUI_PT YEAR
#> 1    01 Alabama      0             All Incomes     11.9 2018
#> 2    01 Alabama      1      <= 200% of Poverty     19.6 2018
#> 3    01 Alabama      2      <= 250% of Poverty     18.5 2018
#> 4    01 Alabama      3      <= 138% of Poverty     20.6 2018
#> 5    01 Alabama      4      <= 400% of Poverty     15.5 2018
#> 6    01 Alabama      5 138% to 400% of Poverty     12.5 2018
```

A more complicated example: Get the uninsured rate (`PCTUI_PT`) and number of unisured people (`NUI_PT`) for non-elderly adults (`AGECAT = 1`) in Florida (`state = 12`) with incomes of 138 to 400% of the poverty line (`IPRCAT = 5`), by race (`RACECAT`) and ethnicity.
```R
sahie_detail <- getCensus(
	name = "timeseries/healthins/sahie",
	vars = c("NAME", "PCTUI_PT", "NUI_PT", "IPR_DESC", "AGE_DESC", "RACECAT", "RACE_DESC"), 
	region = "state:12", 
	year = 2018,
	IPRCAT = 5,
	AGECAT = 1)
sahie_detail
#>   	 state    NAME PCTUI_PT  NUI_PT                IPR_DESC       AGE_DESC RACECAT									RACE_DESC YEAR IPRCAT AGECAT
#>   1    12 Florida     22.3 1220199 138% to 400% of Poverty 18 to 64 years       0                	All Races 2018      5      1
#>   2    12 Florida     19.3  477724 138% to 400% of Poverty 18 to 64 years       1	White alone, not Hispanic 2018      5      1
#>   3    12 Florida     20.2  200193 138% to 400% of Poverty 18 to 64 years       2	Black alone, not Hispanic 2018      5      1
#>   4    12 Florida     28.2  494054 138% to 400% of Poverty 18 to 64 years       3	Black alone, not Hispanic 2018      5      1
```

Read more on how to build a `censusapi` call in [Getting started with censusapi](https://hrecht.github.io/censusapi/articles/getting-started.html) and see examples from every API in the [example master list](https://hrecht.github.io/censusapi/articles/example-masterlist.html).

## Disclaimer
This product uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau.

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/hrecht/censusapi/blob/master/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
