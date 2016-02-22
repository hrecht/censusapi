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

sf3_1990_api <- 'http://api.census.gov/data/1990/sf3'
df1990 <- getCensus(sf3_1990_api, key=censuskey, vars=c("INTPTLAT", "P0070001", "P0070002", "P114A001", "P0570001", "P0570002", "P0570003", "P0570004", "P0570005", "P0570006", "P0570007"), region="county:*")