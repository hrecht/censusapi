# censusapi

Retrieve data from any [Census API](http://www.census.gov/data/developers/data-sets.html), as well as metadata about the [available datasets](http://api.census.gov/data.html) and each API's [variables](http://api.census.gov/data/2000/sf1/variables.html) and [geographies](http://api.census.gov/data/2000/sf1/geography.html).

Note: in very early development. 

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

## Time series notes
Time series 'time' metadata is not yet available. Time field information is found in each API's documentation, so time error handling is being manually added on an API-level basis. Feel free to submit an issue or pull request if your API isn't yet error handled.