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

leeds_university = tmaptools::geocode_OSM("university of leeds", as.sf = TRUE)
leeds_smallarea = stplanr::geo_buffer(shp = leeds_university, dist = 1000)
# sf::st_write(leeds_smallarea, "r5r/leeds_smallarea.geojson")
# download .pbf files here: https://export.hotosm.org/en/v3/exports/4ef4c70c-55be-489c-8b0d-f9c1c7e9ee19

r5r_lts = setup_r5(data_path = "r5r/") #to create new: delete network.dat in the folder. otherwise just load it
# includes .pbf
# includes .zip of FAKE gtfs 
# .tiff of elevation model not included

# export network with osm_id and LTS levels
r5r_lts_shp = street_network_to_sf(r5r_lts)
r5r_lts_edges = r5r_lts_shp$edges
r5r_lts_vert = r5r_lts_shp$vertices
# nrow(r5r_lts_shp) # 10134 edges
# saveRDS(r5r_lts_edges, "r5r/r5r_lts_shp.Rds")
sf::st_write(r5r_lts_edges, "r5r/r5r_lts_shp.geojson")

View(r5r_lts_edges)
table(r5r_lts_edges$bicycle_lts) # 1- no way no how, 4- strong and fearless 

r5r_lts_edges %>% select(bicycle_lts) %>% plot()


## Get original OSM data for this area

library(osmextract)
leeds_osm = oe_get(
  "Leeds",
  quiet = FALSE)

r5r_lts_osmtags = r5r_lts_edges %>% 
  mutate(osm_id = as.character(osm_id)) %>%
  left_join(leeds_osm %>% st_drop_geometry(), by="osm_id")

# saveRDS(r5r_lts_osmtags, "r5r/r5r_lts_osmtags.Rds")
sf::st_write(r5r_lts_osmtags, "r5r/r5r_lts_osmtags.geojson")







# Don't run
# large area - all LEEDS  --------------------------------------------------------------

r5r_lts_large = setup_r5(data_path = "r5r_large/") #to create new, delete network.dat in the folder. otherwise just load it
# includes .pbf
# includes .zip of FAKE gtfs 
# .tiff of elevation model not included

# export network with osm_id and LTS levels
r5r_lts_large_shp = street_network_to_sf(r5r_lts_large)
r5r_lts_large_shp = r5r_lts_large_shp$edges
# nrow(r5r_lts_large_shp) # 338494 edges
saveRDS(r5r_lts_large_shp, "r5r_large/r5r_lts_large_shp.Rds")

r5r_lts_large_shp_osmtags = r5r_lts_large_shp %>% 
  mutate(osm_id = as.character(osm_id)) %>%
  left_join(leeds_osm %>% st_drop_geometry(), by="osm_id")
saveRDS(r5r_lts_large_shp_osmtags, "r5r_large/r5r_lts_large_shp_osmtags.Rds")
