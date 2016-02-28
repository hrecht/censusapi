library(readr)
censuskey <- read_file("/Users/Hannah/Documents/keys/censuskey.txt")

context("getCensus")

test_that("missing Census key returns error", {
	expect_error(getCensus(name="sf3", vintage=1990, vars=c("P0070001"), region="county:*"), "'key' argument is missing. A Census API key is required and can be requested at http://api.census.gov/data/key_signup.html")
})

test_that("time series with invalid years resulting in 204 return appropriate errors", {
	expect_error(getCensus(name="timeseries/healthins/sahie", key=censuskey, vars=c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT", "RACECAT", "RACE_DESC"), region="state:*", time=2050), "Error 204: No content. If using a time series API, check time period inputs - given time period may be unavailable.")
	
	expect_error(getCensus(name="timeseries/poverty/saipe", key=censuskey, vars=c("NAME", "SAEPOVRT0_17_PT", "SAEPOVRTALL_PT"), region="state:*", time=1920), "Error 204: No content. If using a time series API, check time period inputs - given time period may be unavailable.")
})
