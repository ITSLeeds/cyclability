# using r5r
# see: https://ipeagit.github.io/r5r/reference/detailed_itineraries.html

library(dplyr)
library(sf)
# library(rJava)
# Sys.setenv(JAVA_HOME="C:/Program Files/Java/jdk-11.0.11/")
# # get installed version of Java
# .jinit()
# .jcall("java.lang.System","S","getProperty","java.version") #should be 11!
options(java.parameters = '-Xmx8G') #memory max 8GB
library(r5r)


# small test area ---------------------------------------------------------

r5r_lts = setup_r5(data_path = "r5r/") #to create new, delete network.dat in the folder. otherwise just load it
# includes .pbf
# .zip of gtfs not inluded
# .tiff of elevation model not included

# export nework with osm_id and LTS levels
r5r_lts_shp = street_network_to_sf(r5r_lts)
r5r_lts_shp = r5r_lts_shp$edges
# nrow(r5r_lts_shp) # 8686 edes
saveRDS(r5r_lts_shp, "r5r/r5r_lts_shp.Rds")

View(r5r_lts_shp)
table(r5r_lts_shp$bicycle_lts) # 1- no way no how, 4- strong and fearless 



# large area --------------------------------------------------------------

r5r_lts_large = setup_r5(data_path = "r5r_large/") #to create new, delete network.dat in the folder. otherwise just load it
# includes .pbf
# .zip of gtfs not inluded
# .tiff of elevation model not included

# export nework with osm_id and LTS levels
r5r_lts_large_shp = street_network_to_sf(r5r_lts_large)
r5r_lts_large_shp = r5r_lts_large_shp$edges
# nrow(r5r_lts_large_shp) # 338494 edes
saveRDS(r5r_lts_large_shp, "r5r_large/r5r_lts_large_shp.Rds")


