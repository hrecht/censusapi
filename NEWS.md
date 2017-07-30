# censusapi 0.2.1
* Fixes bug in `listCensusMetadata` variables call caused by underlying Census API changes.

# censusapi 0.2.0 (2017-06-04)
* Updated examples, documentation, vignette.

# censusapi 0.1.2
* Fixes bug that caused single-row responses to throw an error

# censusapi 0.1.1
* Uses https rather than http for requests. The Census Bureau [announced](https://content.govdelivery.com/attachments/USCENSUS/2017/05/31/file_attachments/824523/HttpsChangeDocument.pdf) that their APIs will be https-only beginning on August 28, 2017.
* Removes XML dependency by parsing .json instead of .html metadata.
  * Note: this change has generally increased the run time for retrieving variable metadata with `listCensusMetadata`. For most APIs, this function will run in under one second. A lag may be noticeable for the American Community Survey APIs, which each have more than 40,000 variables. Improvements are planned in future releases.
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
