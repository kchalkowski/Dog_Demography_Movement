
#set directories
setwd(this.path::this.dir())
outdir<-file.path("Output")

#source targets file
source("_targets.R")

#Get pipeline
tar_manifest()

#Make pipeline
tar_make()

#tar_visnetwork()

#list("SurvDetProb"=0.9,"Detp"=1)

metadat=tar_read(metadat)
geo=tar_read(geo)
villages=tar_read(vil)
vpol2=tar_read(vpol2)
startlocs<-tar_read(startlocs)
plot(vpol)
compareCRS(crs(vpol),crs(geosf))
geosf2<-tar_read(geosf2)
dogvils<-tar_read(dogvils)

