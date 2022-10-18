# routes from r5r with all attrbutes of LST and quietness and OSM

library(dplyr)
library(sf)
# library(rJava)
# Sys.setenv(JAVA_HOME="C:/Program Files/Java/jdk-11.0.11/")
# # get installed version of Java
# .jinit()
# .jcall("java.lang.System","S","getProperty","java.version") #should be 11!
options(java.parameters = '-Xmx8G') #memory max 8GB
library(r5r)

# get model and extract edges and vertices
r5r_lts = setup_r5(data_path = "r5r/") #to create new: delete network.dat in the folder. otherwise just load it

# sample a OD pairs
od_sample = sample_n(r5r_lts_vert, 4)
mapview::mapview(od_sample)

od_sample = od_sample %>% mutate(lon = as_tibble(st_coordinates(od_sample))$X,
                                 lat = as_tibble(st_coordinates(od_sample))$Y,
                                 id = as.character(c(1,1,2,2))) #only 2 OD pair
origins = od_sample[c(1,3),] %>% st_drop_geometry() %>% select(id, lat, lon)
destinations = od_sample[c(2,4),] %>% st_drop_geometry() %>% select(id, lat, lon)

# routing with r5r for cycling
routes_r5r = detailed_itineraries(r5r_lts,
                                  departure_datetime = Sys.time(),
                                  origins = origins,
                                  destinations = destinations,
                                  mode = "BICYCLE",
                                  max_lts = 4,
                                  max_trip_duration = 60L
                                  )

mapview::mapview(routes_r5r)


# split routes by r5r nodes
# match with other tags: LTS and quietness
routes_r5r_segments = sf::st_join(quietness_lts_osmtags, routes_r5r) %>% filter(!is.na(from_id))

id_overlaps = sf::st_contains_properly(routes_r5r, routes_r5r_segments)
routes_r5r_segments_overlaps = routes_r5r_segments %>% slice(unlist(id_overlaps))

colnames(routes_r5r_segments_overlaps)
routes_r5r_segments_redux = routes_r5r_segments_overlaps %>% mutate(id = as.integer(from_id)) %>%
  select(id, osm_id, total_duration, total_distance, segment, mode, 
         distance, route, street_class, highway, car_speed, speedKmph, 
         bicycle_lts, quietness, walk, car, bicycle,
         other_tags, color, geometry)


# compare results
map_quietness = mapview::mapview(routes_r5r_segments_redux, zcol = "quietness", layer.name = "Cyclestreets - queitness")
map_lts =mapview::mapview(routes_r5r_segments_redux, zcol = "bicycle_lts", layer.name = "r5r - LTS")
leafsync::sync(map_quietness, map_lts)



# rnet
#don't forget the mean(na.rm = TRUE) for quietness