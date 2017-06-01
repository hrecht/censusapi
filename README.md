# censusapi

[![Build Status](https://travis-ci.org/hrecht/censusapi.svg?branch=master)](https://travis-ci.org/hrecht/censusapi)

This package is an accessor for the United States Census Bureau's [APIs](https://www.census.gov/developers/). As of 2017 [over 200 Census API endpoints](https://api.census.gov/data.html) are available, including Decennial Census, American Community Survey, Poverty Statistics, and Population Estimates APIs. censusapi is designed to use the APIs' original parameter names so that users can easily transition between Census's documentation and examples and this package. It also includes functions using the [dataset discovery service](http://www.census.gov/data/developers/updates/new-discovery-tool.html) to return dataset metadata, geographies, and variables as data frames.

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

In some instances you might not want to put your key in your .Renviron - for example, if you're on a shared school computer. You can always choose to manually set `key="YOURKEY"` as an argument in getCensus if you prefer.

## Usage examples
```R
library(censusapi)
```
### Retrieving data with getCensus
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

Get 1990 long-form [Decennial Census](https://www.census.gov/data/developers/data-sets/decennial-census.1990.html) data for all counties

```R
data1990 <- getCensus(name="sf3", vintage=1990, 
	vars=c("P0070001", "P0070002", "P114A001"), 
	region="county:*")
	
head(data1990)
#>   state county P0070001 P0070002 P114A001
#> 1    01    001    16724    17498    11182
#> 2    01    003    47955    50325    12275
#> 3    01    005    12127    13290     9515
#> 4    01    007     8053     8523     8973
#> 5    01    009    19146    20102    10168
#> 6    01    011     5298     5744     6922
```

Get 2015 [5-year American Community Survey](https://www.census.gov/data/developers/data-sets/acs-5year.html) data for each Congressional District in New York state
```R
data2014 <- getCensus(name="acs5", vintage=2014,
	vars=c("NAME", "B01001_001E", "B19013_001E", "B17010_017E", "B17010_037E"), 
	region="congressional district:*", regionin="state:36")
head(data2014)
#>                                                  NAME state congressional.district B01001_001E B19013_001E B17010_017E B17010_037E
#> 1 Congressional District 1 (114th Congress), New York    36                     01      722670       87215        3889       10977
#> 2 Congressional District 2 (114th Congress), New York    36                     02      723744       87938        3285       13857
#> 3 Congressional District 3 (114th Congress), New York    36                     03      720393      101949        1889        8876
#> 4 Congressional District 4 (114th Congress), New York    36                     04      720624       93476        4429       11576
#> 5 Congressional District 5 (114th Congress), New York    36                     05      760308       60767        8530       22470
#> 6 Congressional District 6 (114th Congress), New York    36                     06      721015       58255        4048        9620
```

### Discovering data and variables with metadata functions

Get a data frame of all available APIs and some useful metadata on each.
```R
apis <- listCensusApis()
head(apis)
```

## Time series note
While the APIs generally return specific error messages for invalid variables or geographies, they currently return no content (status 204) without an error message when an invalid year is specified in some time series. If you're getting repeated 204 responses double check the Census documentation to make sure your time period is valid.
