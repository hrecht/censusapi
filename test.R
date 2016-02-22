library(censusapi)
library(readr)
censuskey <- read_file("/Users/Hannah/Documents/keys/censuskey.txt")

# Verify metadata functions
apis <- listCensusApis()
urls <- apis$url
geos <- NULL
for (u in urls) {
	print(u)
	temp <- listCensusMetadata(u, "g")
	temp$url <- u
	geos <- rbind(geos, temp)
}

vars  <- NULL
# Note: this will take a while
for (u in urls) {
	print(u)
	temp <- listCensusMetadata(u, "v")
	temp$url <- u
	vars <- rbind(vars, temp)
}

sf3_1990_api <- 'http://api.census.gov/data/1990/sf3'
df1990 <- getCensus(sf3_1990_api, key=censuskey, vars=c("INTPTLAT", "P0070001", "P0070002", "P114A001", "P0570001", "P0570002", "P0570003", "P0570004", "P0570005", "P0570006", "P0570007"), region="county:*")

# Error handling for missing key
df1990 <- getCensus(sf3_1990_api, vars=c("P0070001"), region="county:*")

# Time series APIs - note: the arguments vary by API. Read the documentation, i.e. http://www.census.gov/data/developers/data-sets/population-estimates-and-projections.html
pep_api <-'https://api.census.gov/data/2015/pep/components'
pep <- getCensus(pep_api, key=censuskey, vars=c("BIRTHS", "DEATHS"), region="state:*", period=6)

# SAHIE
# Note: some categories (racial breakdown) appear not to be available at state level - will return only 'all races'
sahie_api <- 'http://api.census.gov/data/timeseries/healthins/sahie'
sahie <- getCensus(sahie_api, key=censuskey, vars=c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT", "RACECAT", "RACE_DESC"), region="state:*", time=2011)


saipe_api <- 'http://api.census.gov/data/timeseries/poverty/saipe'
saipe <- getCensus(saipe_api, key=censuskey, vars=c("NAME", "SAEPOVRT0_17_PT", "SAEPOVRTALL_PT"), region="state:*", time=2011)
# Verify error handling for bad years
sahie <- getCensus(sahie_api, key=censuskey, vars=c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT", "RACECAT", "RACE_DESC"), region="state:*", time=2015)
saipe <- getCensus(saipe_api, key=censuskey, vars=c("NAME", "SAEPOVRT0_17_PT", "SAEPOVRTALL_PT"), region="state:*", time=1920)

# ACS, and test 50+ variable splitting
acs_2014_api <- 'http://api.census.gov/data/2014/acs5'

myvars <- c("B01001_001E", "NAME", "B01002_001E", "B19013_001E", "B19001_001E", "B03002_012E")
myvars2 <- paste('B04004_', sprintf('%03i', seq(1, 105)), 'E', sep='')

df <- getCensus(acs_2014_api, key=censuskey, vars=myvars, region="tract:*&in=state:06")
df2 <- getCensus(acs_2014_api, key=censuskey, vars=myvars2, region="state:*")

tracts <- NULL
for (f in fips) {
	regionget <- paste("tract:*&in=state:", f, sep="")
	temp <- getCensus(acs_2014_api, key=censuskey, vars=myvars, region=regionget)
	tracts <- rbind(tracts, temp)
}