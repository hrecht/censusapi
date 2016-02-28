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

df1990 <- getCensus(name="sf3", vintage=1990, key=censuskey, vars=c("INTPTLAT", "P0070001", "P0070002", "P114A001", "P0570001", "P0570002", "P0570003", "P0570004", "P0570005", "P0570006", "P0570007"), region="county:*")

# Time series APIs - note: the arguments vary by API. Read the documentation, i.e. http://www.census.gov/data/developers/data-sets/population-estimates-and-projections.html
pep <- getCensus(name="pep/components", vintage=2015, key=censuskey, vars=c("BIRTHS", "DEATHS"), region="state:*", period=6)

# SAHIE
# Note: some categories (racial breakdown) appear not to be available at state level - will return only 'all races'
sahie <- getCensus(name="timeseries/healthins/sahie", key=censuskey, vars=c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT", "RACECAT", "RACE_DESC"), region="state:*", time=2011)

saipe <- getCensus(name="timeseries/poverty/saipe", key=censuskey, vars=c("NAME", "SAEPOVRT0_17_PT", "SAEPOVRTALL_PT"), region="state:*", time=2011)

# ACS, and test 50+ variable splitting

myvars <- c("B01001_001E", "NAME", "B01002_001E", "B19013_001E", "B19001_001E", "B03002_012E")
df <- getCensus(name="acs5", vintage=2014, key=censuskey, vars=myvars, region="county:*", regionin="state:36")

myvars2 <- paste('B04004_', sprintf('%03i', seq(1, 105)), 'E', sep='')
df2 <- getCensus(name="acs5", vintage=2014, key=censuskey, vars=myvars2, region="state:5,6")

tracts <- NULL
for (f in fips) {
	stateget <- paste("state:", f, sep="")
	temp <- getCensus(name="acs5", vintage=2014, key=censuskey, vars=myvars, region="tract:*", regionin=stateget)
	tracts <- rbind(tracts, temp)
}
