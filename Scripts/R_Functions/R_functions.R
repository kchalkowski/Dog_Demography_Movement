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
	dogvils
	geo2=left_join(geo,dogvils,by="Dog")
	return(geo2)
	}



