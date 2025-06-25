# _targets.R

# Targets setup --------------------
setwd(this.path::this.dir())

#load libraries for targets script
#install.packages("geotargets", repos = c("https://njtierney.r-universe.dev", "https://cran.r-project.org"))
library(targets)
library(tarchetypes)
library(geotargets)

# This hardcodes the absolute path in _targets.yaml, so to make this more
# portable, we rewrite it every time this pipeline is run (and we don't track
# _targets.yaml with git)
tar_config_set(
  store = file.path(this.path::this.dir(),("_targets")),
  script = file.path(this.path::this.dir(),("_targets.R"))
)

#Source functions in pipeline
lapply(list.files(file.path("Scripts","R_Functions"), full.names = TRUE, recursive = TRUE), source)

#Load packages
tar_option_set(packages = c("Rcpp",
                            "stringr",
                            "dplyr",
                            "sf",
                            "raster",
                            "terra",
														"amt"))

# Pipeline ---------------------------------------------------------

list(
  
  ## Input raw data file paths -----  

  ### Input metadata: -----------
  tar_target(metadat_path,
             file.path("Data","Dogs_collaring_metadata.csv"),
             format="file"),
  
  ### Input geolocation data: -----------
  tar_target(geo_path,
             file.path("Data","Dog_tracks_combined.csv"),
             format="file"),
	
	### Input villages df: -----------
  tar_target(vil_path,
             file.path("Data","villages.csv"),
             format="file"),
	
	### Input land cover raster: -----------
  tar_target(land_path,
             file.path("Data","ZOI2_LU_classification_39s1.tif"),
             format="file"),
	
	### Input villages polygons: -----------
  tar_target(vpol_path,
             file.path("Data","Andasibe_Dogs_Polygons.shp"),
             format="file"),
	
	## Read in all input data -----  

  ### Read and format parameters file: -----------
  tar_target(metadat0,ReadCSV(metadat_path)),
  tar_target(geo0,ReadCSV(geo_path)),
  tar_target(vil0,ReadCSV(vil_path)),

  ## Read and format landscapes: -----------
	
	### Input land cover raster: -----------
	tar_terra_rast(lands, ReadLands(land_path)), 
	
	## Read and format village polygons: -----------
  tar_target(vpol0, ReadPoly(vpol_path)),
	
	## Tidy data: -----------
	tar_target(metadat, TidyMetadat(metadat0)),
	tar_target(geo, TidyGeo(geo0)),
	tar_target(vil, TidyVil(vil0)),
	tar_target(vpol, TidyVpol(vpol0,vil)),
	
  ## Formatting -----
  tar_target(geosf,Format_SF(geo,4326,5,4)),
	tar_target(geosf2,FormatDT(geosf)),
	tar_target(startlocs,DogStartLocs(geosf2)),
  tar_target(vpol2,MakeValidSF(vpol)),

	## Join data -----
  tar_target(dogvils,JoinVillageData(vil, vpol2, startlocs, lands)),
	tar_target(geo2,JoinGeolocationVillages(geo,dogvils)),
	tar_target(geo4,JoinGeolocationLC(geo2,lands)),
	
	## Analyze movement -----
	tar_target(trk2,ResampleGeolocations(geo4)),
	tar_target(dog_trk_models,RunSSF(trk2,lands))#,
	
  )
