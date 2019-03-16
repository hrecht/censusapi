# censusapi 0.6.0
* Returns underlying API call in error messages, particularly useful for users needing from the Census Bureau.
* Specifies tract in block group example due to underlying API changes.

# censusapi 0.5.0
* Makes `region` an optional argument in `getCensus`, rather than required.
* Pads fips codes stored in `fips` dataset with zeroes.

# censusapi 0.4.1
* Adds `groups` type option to `listCensusMetadata`.
* Fixes bug in `listCensusMetadata` variables call caused by an underlying Census API change, which renamed `validValues` to `values` for some endpoints.
* Converts variable metadata columns from factors to characters.
* Applies numeric conversion exclusions to all API endpoints.
* Improves language surrounding error messages that the Census Bureau returns.
* Updates 2010 Decennial Census examples to use new 2010 `dec/sf1` endpoint, which will replace 2010 `sf1` endpoint on August 30, 2018.

# censusapi 0.4.0
* Adds support for NAICS code arguments used in [Business Patterns](https://www.census.gov/data/developers/data-sets/cbp-nonemp-zbp.html) APIs, [Economic Census](https://www.census.gov/data/developers/data-sets/economic-census.html) APIs, and [Annual Survey of Manufactures](https://www.census.gov/data/developers/data-sets/Annual-Survey-of-Manufactures.html) APIs.

# censusapi 0.3.0
* Does not convert ACS annotation flag variables into numeric columns.
* Puts lowercase variable name columns first (geographies), rather than all non-numeric columns.
* Changes all punctuation in returned column names into underscores, removing repeated underscores and trailing punctuation.
* Uses consistent spacing in examples.
* Updates examples using ACS data to latest year using new acs/acs5 endpoint and adds variable group examples.

# censusapi 0.2.1
* Fixes bug in `listCensusMetadata` variables call caused by underlying Census API changes.

# censusapi 0.2.0
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
