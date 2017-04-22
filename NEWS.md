censusapi

# 0.1.0.9000

* Set `getCensus(key)` argument's default value to be CENSUS_KEY in .Renviron. Explicitly encourages Census key to be added to .Renviron. (Users can always override this with any given input.)
* Parses HTML response code. This is particularly important for the response that the Census APIs provided for invalid keys.

# 0.1.0

* Removes fips code 72 (Puerto Rico) from included fips dataset because Puerto Rico is not included in most Census API datasets.
* Changes census key references in examples to Sys.getenv("CENSUS_KEY").
