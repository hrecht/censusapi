# censusapi

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/censusapi)](https://CRAN.R-project.org/package=censusapi)
[![CRAN downloads badge](http://cranlogs.r-pkg.org/badges/grand-total/censusapi)](http://cranlogs.r-pkg.org/badges/grand-total/censusapi)
[![R-CMD-check](https://github.com/hrecht/censusapi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hrecht/censusapi/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`censusapi` is a lightweight package to get data from the U.S. Census Bureau's [APIs](https://www.census.gov/developers/). More than [1,000 Census API endpoints](https://api.census.gov/data.html) are available, including the Decennial Census, American Community Survey, Poverty Statistics, Population Estimates, and Census microdata. This package is designed to let you get data from all of those APIs using the same main functions and syntax for every dataset.

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

To learn more about using `censusapi`, read the package documentation and articles at  [https://www.hrecht.com/censusapi/.](https://www.hrecht.com/censusapi/)

## Disclaimer
This product uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau.

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/hrecht/censusapi/blob/main/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
