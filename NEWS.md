# censusapi 0.1.1.0
* Uses https rather than http for requests. The Census APIs will no longer work on http on August 28, 2017.
* Removes XML dependency by parsing .json instead of .html metadata.
* `listCensusMetadata` allows full word or single letter argument in `type` parameter

# censusapi 0.1.0.9001
* Scrapes http://api.census.gov/data.json rather than .html in `listCensusApis`, in starts of removing XML dependency. The .json data also includes several fields not present in the .html file, the most useful of which are added to the returned data frame.
* Changes dataset used in `listCensusMetadata` examples, mainly for build/checks speed.

# censusapi 0.1.0.9000
* Set `getCensus(key)` argument's default value to be CENSUS_KEY in .Renviron. Explicitly encourages Census key to be added to .Renviron. (Users can always override this with any given input.)
* Parses HTML response code. This is particularly important for the response that the Census APIs provided for invalid keys.

# censusapi 0.1.0
* Removes fips code 72 (Puerto Rico) from included fips dataset because Puerto Rico is not included in most Census API datasets.
* Changes census key references in examples to Sys.getenv("CENSUS_KEY").
