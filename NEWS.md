# censusapi 0.8.0 
* `listCensusApis()` has new columns in the resulting data frame of available API endpoints: the API `contact` email address and `type`: either Aggregate, Timeseries, or Microdata.
* `listCensusMetadata()` has new functionality to use `value` metadata. This is particularly useful for some of the economic datasets and the microdata APIs.
	Use `type = "variables"` and `include_values = TRUE` to create a dictionary with all value labels for a given dataset.
	To get value labels for a single variable in a given dataset, use `type = "values"` and `variable = "VARIABLE OF INTEREST"`. 

	Note: This metadata, while incredibly useful, only exists for some datasets. For other datasets you'll still need to reference external files until the Census Bureau adds this functionality.
	
  For example, get the value labels for the `NAICS2017` in the County Business Patterns dataset:

	```R 
	cbp_naics_values <- listCensusMetadata(
		name = "cbp",
		vintage = 2020,
		type = "values",
		variable = "NAICS2017")
	```
	
	Or make a full dictionary for the Current Population Survey Voting Patterns microdata API:
	
	```R 
	cbp_dict <- listCensusMetadata(
		name = "cbp",
		vintage = 2020,
		type = "variables",
		include_values = TRUE)
	```


* `getCensus()` has a new option `convert_variables` re discussion in (#68) and (#80). The default is `TRUE` — as in previous versions, this converts columns of numbers to R's numeric data type. Setting `convert variables = FALSE` leaves all columns in the original character data type returned by the Census Bureau.
* `getCensus()` has improved data binding for responses from requests where more than 50 variables are manually specified. Occasionally these large requests were not returned from the Census Bureau in the same order, leading to mismatched rows. This fixes (#82).
* `listCensusMetadata()` now properly handles metadata attribute names in the new Microdata APIs that contain invalid JSON. This fixes (#84).
* Documentation and examples are updated. There is a new vignette: [Accessing microdata.](https://www.hrecht.com/censusapi/articles/accessing-microdata.html)

# censusapi 0.7.3
* Properly types certain variables in international trade timeseries APIs.

# censusapi 0.7.2
* Adds named parameter for `YEAR` to `getCensus()` per changes to some timeseries endpoints that previously used `TIME` as a parameter.
* Updates examples using SAHIE and SAIPE APIs per Census Bureau changes to these endpoints.

# censusapi 0.7.1
* Removes `listCensusMetadata()` and masterlist examples that used Business Dynamic Statistics endpoints, which were recently deprecated.

# censusapi 0.7.0
* Adds `show_call` option to `getCensus()`, which shows the underlying API call (otherwise only shown on errors) and link to package documentation when used.
* Converts improperly formatted string "N/A" and "NULL" values from underlying Census data to true NA values.
* Improves parsing of columns as numeric or character, specifically:
  * Keeps 2017 NAICS variables as characters, instead of erroneously converting to numeric.
  * Parses endpoint numeric variables with all-character variable names as numeric for several popular endpoints: SAHIE, SAIPE, ZBP, CBP, PEP and Decennial Response Rates.
* Removes examples from deprecated 1990 and 2000 Decennial endpoints.

# censusapi 0.6.1
* Updates web link to FIPS codes reference after Census website reorganization.
* Adds examples for Decennial Census response rates, updates several examples to retrieve newer data.
* Removes example masterlist from package itself due to size, online only.

# censusapi 0.6.0
* Allows the use of miscellaneous paramaters in `getCensus()`. This allows users to specify any valid API argument name and pass it a value, giving full access to all of the underlying Census Bureau APIs.
* Adds a `group` parameter in `listCensusMetadata()`. This allows users to get variable metadata for a specified variable group.
* Improves internal logic in `listCensusMetadata()`.
* Add documentation and examples using miscellaneous paramaters.
* Returns underlying API call in error messages, particularly useful for users needing from the Census Bureau.
* Specifies tract in block group example due to underlying API changes.
* Adds Contributor Code of Conduct.

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

# censusapi 0.1.0
* Scrapes http://api.census.gov/data.json rather than .html in `listCensusApis`, in starts of removing XML dependency. The .json data also includes several fields not present in the .html file, the most useful of which are added to the returned data frame.
* Changes dataset used in `listCensusMetadata` examples, mainly for build/checks speed.
* Set `getCensus(key)` argument's default value to be CENSUS_KEY in .Renviron. Explicitly encourages Census key to be added to .Renviron. (Users can always override this with any given input.)
* Parses HTML response code. This is particularly important for the response that the Census APIs provided for invalid keys.
* Removes fips code 72 (Puerto Rico) from included fips dataset because Puerto Rico is not included in most Census API datasets.
* Changes census key references in examples to Sys.getenv("CENSUS_KEY").
