# censusapi

[![Build Status](https://travis-ci.org/hrecht/censusapi.svg?branch=master)](https://travis-ci.org/hrecht/censusapi) [![CRAN Badge](https://www.r-pkg.org/badges/version/censusapi)](https://cran.r-project.org/package=censusapi)

`censusapi` is an accessor for the United States Census Bureau's [APIs](https://www.census.gov/developers/). More than [300 Census API endpoints](https://api.census.gov/data.html) are available, including Decennial Census, American Community Survey, Poverty Statistics, and Population Estimates APIs. This package is designed to let you get data from all of those APIs using the same main function—`getCensus`—and the same syntax for each dataset.

`censusapi` generally uses the APIs' original parameter names so that users can easily transition between Census's documentation and examples and this package. It also includes metadata functions to return data frames of available APIs, variables, and geographies.

## Installation
Get the latest stable release from CRAN: 
```R
install.packages("censusapi")
```

You can also install the latest development version of `censusapi` from Github using `devtools`. Most people will not want to do this:
```R
# install.packages("devtools")
devtools::install_github("hrecht/censusapi")
```

Read more on how to build a `censusapi` call in [Getting started with censusapi](https://hrecht.github.io/censusapi/articles/getting-started.html) and see lots more examples in the [list of examples](https://hrecht.github.io/censusapi/articles/example-masterlist.html).

## Disclaimer
This product uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau.

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/hrecht/censusapi/blob/master/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
