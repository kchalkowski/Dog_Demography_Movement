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

TidyVpol<-function(vpol){
	vpol[,which(colnames(vil)=="Name")]
}


# Format data ------
#crs_num=4326
#xcol=5
#ycol=4
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

IntersectLayers<-function(startlocs, vpol2){
	vpol3=sf::st_zm(vpol2)
	svil=sf::st_intersection(startlocs, vpol3)
	svil=st_drop_geometry(svil[,c(1,2)])
	
	no_int=which(!(startlocs$ID%in%svil$ID))
	no_int_locs=data.frame("ID"=startlocs$ID[no_int],"Name"=c(442,466,484,466))
	dogvils=rbind(svil,no_int_locs)
	return(dogvils)
}


#didn't intersect, should be is below
#Bojira, 442
#Fox, 466
#Poky, 484
#Regarde, 466

#which(!(st_is_valid(vpol2)))


