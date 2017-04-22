context("getCensus")

test_that("missing Census key returns error", {
	expect_error(getCensus(name="sf3", vintage=1990, vars=c("P0070001"), key = "a failing fake key", region="state:*"))
})

test_that("time series with invalid years resulting in 204 return appropriate errors", {
	expect_error(getCensus(name="timeseries/healthins/sahie", key=Sys.getenv("CENSUS_KEY"), vars=c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT"), region="state:*", time=2050), "204, no content. If using a time series API, check time period inputs - given time period may be unavailable.")

	expect_error(getCensus(name="timeseries/poverty/saipe", key=Sys.getenv("CENSUS_KEY"), vars=c("NAME", "SAEPOVRT0_17_PT", "SAEPOVRTALL_PT"), region="state:*", time=1920), "204, no content. If using a time series API, check time period inputs - given time period may be unavailable.")
})
