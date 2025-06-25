# Read files ------

ReadCSV<-function(path){
	read.csv(path)
}

ReadLands<-function(path){
	terra::rast(path)
}

ReadPoly<-function(path){
	st_read(path)
}

# Tidy data ------
TidyMetadat<-function(metadat){
	complete.cases(metadat[,which(colnames(metadat)=="X")])
}

TidyGeo<-function(geo){
	geo=geo[,1:5]
}

TidyVil<-function(vil){
	vil[,-c(which(colnames(vil)=="X"),
					which(colnames(vil)=="object_"),
					which(colnames(vil)=="object_"),
					which(colnames(vil)=="ID"),
					which(colnames(vil)=="centdist_m"))
		]
}

TidyVpol<-function(vpol,vil){
	vpol[,which(colnames(vil)=="Name")]
}


# Format data ------
Format_SF<-function(geo,crs_num,xcol,ycol){
	sf::st_as_sf(geo,coords=c(xcol,ycol),crs=st_crs(crs_num))
}

MakeValidSF<-function(vpol){
	vpol[c(1:6,8:35,37:614,616:nrow(vpol)),]
	#which(!(st_is_valid(vpol)))
}

Transform_SF<-function(geo,crs_num){
	sf::st_transform(geo,crs=st_crs(crs_num))
}

#format datetimes
FormatDT<-function(geosf){
	geosf$datetime=as.POSIXct(paste(geosf$date, geosf$time),
									format="%d/%m/%y %H:%M:%OS")
	return(geosf)
}

#get starting locations for each dog
DogStartLocs<-function(geosf2){
	geosf2$x=st_coordinates(geosf2)[,1]
	geosf2$y=st_coordinates(geosf2)[,2]
	startlocs=geosf2 %>% 
						dplyr::group_by(ID) %>% 
						dplyr::summarise(startx=dplyr::first(x),
														 starty=dplyr::first(y)) %>%
						as.data.frame() 
	startlocs=startlocs[,1:3]
	
	startlocs=st_as_sf(startlocs,coords=c(2,3),crs=st_crs(4326))
	
	return(startlocs)
	}

#get starting locations for each dog
Transform_SF<-function(geo,crs_num){
	sf::st_transform(geo,crs=st_crs(crs_num))
	}

# Join data ------

JoinVillageData<-function(villages, vpol2, startlocs, lands){
	vpol3=sf::st_zm(vpol2)
	vpol4<-st_transform(vpol3,crs=st_crs(lands))
	villages<-st_as_sf(villages,coords=c("x","y"),crs=st_crs(lands))
	startlocs2<-st_transform(startlocs,crs=st_crs(lands))
	
	#join village polygons to village info
	#vpol_info<-st_intersection(villages,vpol4)

	#Note: not all polygons are picked up in this intersection-- due to shapes of polygons, some don't overlap with the centroid
	#purpose of this is to intersect with dog origins anyways, so this isn't a problem unless a dog village is one that wasn't picked up
	#dogvils<-st_(startlocs2,vpol4)
	
	#Join village polygons with dog names (startlocs2)
	startvil_indices=st_nearest_feature(startlocs2,vpol4)
	startvils=vpol4[startvil_indices,]
	startvils$Dog=startlocs2$ID
	
	#Join dog village polygons with village polygons
	vill_0<-st_nearest_feature(startvils,villages)
	#vil_indices=which(vill_indices==min(vill_indices))
	
	dogvils=villages[vill_0,]
	startvils$Houses<-dogvils$Houses
	startvils$VilName<-dogvils$Name
	
	#Get distance to Andasibe (row 397) for each dog origin village
	Andasibe<-vpol4[397,]
	startvils$Andasibe_m=st_distance(startvils,Andasibe)
	
	#reorganize so that geometry at end column
	dogvils_out<-startvils[,c(3,4,5,6,2)]
	
	return(dogvils_out)
	
}

JoinGeolocationVillages<-function(geo,dogvils){
	colnames(geo)[which(colnames(geo)=="ID")]<-"Dog"
	#dogvils
	geo2=left_join(geo,dogvils,by="Dog")
	geo2<-st_drop_geometry(geo2)
	geo2<-geo2[,1:8]
	return(geo2)
	}

JoinGeolocationLC<-function(geo2,lands){
	geo3<-st_as_sf(geo2,coords=c(5,4),crs=st_crs(4326))
	geo4<-st_transform(geo3,crs=st_crs(lands))
	lcvals=terra::extract(lands,st_coordinates(geo4))
	colnames(lcvals)="lc"
	geo4$lc=lcvals$lc
	geo4=geo4[,c(1:6,8,7)]
	return(geo4)
	}

# Resample data ------
ResampleGeolocations<-function(geo4){
	
	#format for make track
	geo4$x=st_coordinates(geo4)[,1]
	geo4$y=st_coordinates(geo4)[,2]
	geo4$date=as.Date(geo4$date,"%d/%m/%y")
	
	#remove NA datetimes
	geo4=geo4[!is.na(geo4$date),]
	
	geo4$datetime=paste0(geo4$date," ",geo4$time)
	geo4$datetime=Neat.Dates.POSIXct(geo4$datetime,tz="Indian/Antananarivo")
	trk=make_track(geo4,x,y,datetime,all_cols=TRUE,crs=st_crs(geo4))
	ssr=summarize_sampling_rate(trk)
	trk2=trk |> track_resample(rate = minutes(ssr$median), tolerance = minutes(as.integer(ssr$median*0.3)))
	return(trk2)
	}

# RunSSF ------
RunSSF<-function(trk2,lands){
	#Nest data by ID
	trk3 <- trk2 |> nest(data = -"Dog")
	trk3=trk3 |> 
  mutate(steps = map(data, function(x) 
    x |> steps_by_burst()))
	
	trk3=trk3 |> 
  mutate(nrow = map(steps, function(x) 
    x |> nrow()))
	
	tfil=trk3[trk3$nrow>=40,]
	
	landfor=lands
	landfor[landfor==5]<-0 #open
	landfor[landfor==4]<-0 #open
	landfor[landfor==2]<-4 #scrub/fallow
	landfor[landfor==3]<-4 #scrub/fallow
	landfor[landfor==1]<-5 #forest
	#recode to make sense, levels in order
	landfor[landfor==4]<-1 #scrub/fallow
	landfor[landfor==5]<-2 #forest
	
	tfil <- tfil |> mutate(randomsteps = map(steps, function(x)
		x |> random_steps(n_control=15) |> 
			extract_covariates(landfor)
	))
	
tfil <- tfil |> mutate(models = map(randomsteps, function(x)
		x |> fit_clogit(case_ ~ factor(ZOI2_LU_classification_39s1) + strata(step_id_))
	))
	
dog_trk_models=tfil |> select(Dog,models)

return(dog_trk_models)

	}

