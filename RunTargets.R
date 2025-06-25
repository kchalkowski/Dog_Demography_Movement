
#set directories
setwd(this.path::this.dir())
outdir<-file.path("Output")

#source targets file
source("_targets.R")

#Get pipeline
tar_manifest()

#Make pipeline
tar_make()



metadat=tar_read(metadat)
geo=tar_read(geo)
villages=tar_read(vil)
vpol<-tar_read(vpol)
vpol2=tar_read(vpol2)
startlocs<-tar_read(startlocs)
geosf<-tar_read(geosf)
geosf2<-tar_read(geosf2)
lands<-tar_read(lands)
compareCRS(crs(vpol2),crs(geosf))
dogvils<-tar_read(dogvils)
geo2<-tar_read(geo2)
geo4<-tar_read(geo4)
trk2<-tar_read(trk2)




