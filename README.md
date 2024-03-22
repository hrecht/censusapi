# censusapi

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/censusapi)](https://CRAN.R-project.org/package=censusapi)
[![CRAN downloads badge](https://cranlogs.r-pkg.org:443/badges/grand-total/censusapi)](https://cranlogs.r-pkg.org:443/badges/grand-total/censusapi)
[![R-CMD-check](https://github.com/hrecht/censusapi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hrecht/censusapi/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`censusapi` is a lightweight package to get data from the U.S. Census Bureau's [APIs](https://www.census.gov/data/developers.html). More than [1,000 Census API endpoints](https://api.census.gov/data.html) are available, including the Decennial Census, American Community Survey, Poverty Statistics, Population Estimates, and Census microdata. This package is designed to let you get data from all of those APIs using the same main functions and syntax for every dataset.

`getCensus()` is designed to work with any new Census API endpoint when it is released, as long as it conforms to Census's existing standards. The package also includes metadata functions so that users determine [which datasets](https://www.hrecht.com/censusapi/reference/listCensusApis.html) are available and [for each dataset](https://www.hrecht.com/censusapi/reference/listCensusMetadata.html), what variables, geographies, and groups can be used.

## Installation
Get the latest stable release from CRAN: 
```R
install.packages("censusapi")
```

You can also install the latest development version of `censusapi` from Github using `devtools`:
```R
# Install the devtools package if needed
# install.packages("devtools")
devtools::install_github("hrecht/censusapi")
```

## Basic usage
Using the [Small Area Income and Poverty Estimates](https://www.census.gov/data/developers/data-sets/Poverty-Statistics.html) dataset, get the poverty rate [(SAEPOVRTALL_PT)](https://api.census.gov/data/timeseries/poverty/saipe/variables/SAEPOVRTALL_PT.html) for every year since 2010 in Los Angeles County, CA.

```R
poverty_rate <- getCensus(
	name = "timeseries/poverty/saipe",
	vars = c("NAME", "SAEPOVRTALL_PT"),
	region = "county:037",
	regionin = "state:06",
	time = "from 2010")

poverty_rate
#>    time 	state county NAME 				SAEPOVRTALL_PT
#> 1  2010  06    037 	 Los Angeles County           17.6
#> 2  2011  06    037    Los Angeles County           18.4
#> 3  2012  06    037    Los Angeles County           19.1
#> 4  2013  06    037    Los Angeles County           19.0
#> 5  2014  06    037    Los Angeles County           18.7
#> 6  2015  06    037    Los Angeles County           16.7
#> 7  2016  06    037    Los Angeles County           16.3
#> 8  2017  06    037    Los Angeles County           14.9
#> 9  2018  06    037    Los Angeles County           14.2
#> 10 2019  06    037    Los Angeles County           13.4
#> 11 2020  06    037    Los Angeles County           13.2
#> 12 2021  06    037    Los Angeles County           14.1
#> 13 2022  06    037    Los Angeles County           13.9

```

Using the 2022 [5-year American Community Survey](https://www.census.gov/data/developers/data-sets/acs-5year.html) Subject Tables dataset, for all Census tracts in Arizona, get the:

* total number of households [(S2801_C01_001E)](https://api.census.gov/data/2022/acs/acs5/subject/variables/S2801_C01_001E.html)
* number of households without an internet subscription [(S2801_C01_019E)](https://api.census.gov/data/2022/acs/acs5/subject/variables/S2801_C01_019E.html)
* percent of households without an internet subscription [(S2801_C02_019E)](https://api.census.gov/data/2022/acs/acs5/subject/variables/S2801_C02_019E.html)
* Census tract name

```R
no_internet <- getCensus(
	name = "acs/acs5/subject",
	vintage = 2022,
	vars = c("S2801_C01_001E", "S2801_C01_019E", "S2801_C02_019E", "NAME"),
	region = "tract:*",
	regionin = "state:04")

head(no internet)
#> 	 state county tract   S2801_C01_001E S2801_C01_019E	S2801_C02_019E NAME 										 
#> 1 04    001 	  942600			 429            412		   	  96.0 Census Tract 9426; Apache County; Arizona    			
#> 2 04    001 	  942700			1439           1006			  69.9 Census Tract 9427; Apache County; Arizona    		   
#> 3 04    001 	  944000			1556            903			  58.0 Census Tract 9440; Apache County; Arizona    		   
#> 4 04    001 	  944100			1446            966			  66.8 Census Tract 9441; Apache County; Arizona    		   
#> 5 04    001 	  944201 			1154            835			  72.4 Census Tract 9442.01; Apache County; Arizona 		   
#> 6 04    001 	  944202			1111            874			  78.7 Census Tract 9442.02; Apache County; Arizona 		   

```

To learn more about using `censusapi`, read the package documentation and articles at  [https://www.hrecht.com/censusapi/.](https://www.hrecht.com/censusapi/)

## Disclaimer
This product uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau.

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/hrecht/censusapi/blob/main/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
