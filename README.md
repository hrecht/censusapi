# censusapi

Retrieve data from any [Census API](http://www.census.gov/data/developers/data-sets.html), as well as metadata about the [available datasets](http://api.census.gov/data.html) and each API's [variables](http://api.census.gov/data/2000/sf1/variables.html) and [geographies](http://api.census.gov/data/2000/sf1/geography.html).
Function getCensus builds on work by [Nicholas Nagle](https://rpubs.com/nnnagle/19337).

Note: in very early development. 

## Installation

```R
# install.packages("devtools")
devtools::install_github("hrecht/censusapi")
```

## Why?
There are a few other packages dealing with the Census APIs, but so far they all only take calls for some of the available APIs (e.g. ACS, decennial). This package is dataset agnostic.