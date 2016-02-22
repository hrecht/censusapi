library(censusapi)
library(readr)
censuskey <- read_file("/Users/Hannah/Documents/keys/censuskey.txt")

acs_2014_api <- 'http://api.census.gov/data/2014/acs5'

myvars <- c("B01001_001E", "NAME", "B01002_001E", "B19013_001E", "B19001_001E", "B03002_012E")
myvars2 <- paste('B04004_', sprintf('%03i', seq(1, 105)), 'E', sep='')

dt <- getCensus(acs_2014_api, key=censuskey, vars=myvars, region="tract:*&in=state:06")
dt2 <- getCensus(acs_2014_api, key=censuskey, vars=myvars2, region="state:*")