library(tidyverse)

leeds_lts = readRDS("r5r/r5r_lts_osmtags.Rds")
leeds_quietness = sf::read_sf("cyclestreets/leeds_quietness.geojson")
mapview::mapview(leeds_quietness)

# Join when we have IDs
leeds_lts_with_quietness = left_join(
  leeds_lts,
  leeds_quietness |>
    transmute(osm_id = as.character(id), quietness) |>
    sf::st_drop_geometry()
)
mapview::mapview(leeds_lts_with_quietness, zcol = "quietness")

leeds_lts_with_quietness = leeds_lts_with_quietness %>% select(osm_id, bicycle_lts, quietness)

# Routes that overlap
routes_r5r_overlap = sf::st_read("r5r/routes_r5r_overlap.geojson")
mapview::mapview(routes_r5r_overlap)
summary(sf::st_length(routes_r5r_overlap))
routes_r5r_overlap$id = routes_r5r_overlap$from_id
nrow(routes_r5r_overlap) # 2

# Overline to split routes and reduce (if many in a network)
rnet_r5r = stplanr::overline(routes_r5r_overlap, attrib = "distance")
rnet_r5r$id = seq(nrow(rnet_r5r)) %>% as.character()
nrow(rnet_r5r) # 7
# but they don't come with an ID


# Project road network and routes
routes_r5r_projected = sf::st_transform(routes_r5r_overlap, crs = 3857)
rnet_r5r_projected = sf::st_transform(routes_r5r_overlap, crs = 3857)
alltags_projected = sf::st_transform(leeds_lts_with_quietness, crs = 3857)
buffer_length = 1 # buffer width

# Buffer rnet
rnet_r5r_buffer = rnet_r5r_projected |> 
  sf::st_buffer(dist = buffer_length)

# Joining data from the longer segments, generates few duplicated geometries
alltags_with_id = sf::st_join(
  alltags_projected |> 
    select(quietness),
  rnet_r5r_buffer |> select(id),
  join = sf::st_within
)
nrow(alltags_with_id) #10156
nrow(alltags_projected) #10134

# summarize network with quietness levels
alltags_summary = alltags_with_id |> 
  sf::st_drop_geometry() |> 
  # filter (!is.na(id)) |> 
  group_by(id) |> 
  summarise(
    quietness_mean = round(mean(quietness, na.rm = TRUE)),
    quietness_min = round(min(quietness, na.rm = TRUE))
  )

# join quietness in routes
rnet_with_quietness = left_join(
  rnet_r5r,
  alltags_summary
)
rnet_with_quietness$length = as.numeric(sf::st_length(rnet_with_quietness))

summary(duplicated(sf::st_as_text(rnet_with_quietness$geometry)))

# map and compare
mapresults = mapview::mapview(rnet_with_quietness, zcol = "id", lwd = 3)
mapquietness = mapview(leeds_lts_with_quietness, zcol = "quietness")
leafsync::sync(mapresults, mapquietness)



rnet_with_quietness_redux = rnet_buffer_with_quietness |> 
  group_by(distance) |> 
  summarise(quietness = mean(quietness, na.rm = TRUE))

rnet_with_quietness













# other -------------------------------------------------------------------




# Keeping segment level data from the OSM dataset
quietness_with_id = sf::st_join(
  leeds_quietness_projected |> 
    select(quietness),
  rnet_buffer,
  join = sf::st_within
)
quietness_with_id_minimal = quietness_with_id |> 
  filter(!is.na(id))

vertices = sf::read_sf("r5r/r5r_lts_vert.geojson")
vertices = sf::st_transform(vertices, crs = "EPSG:27700")
quietness_broken_up = stplanr::rnet_breakup_vertices(quietness_with_id_minimal)
quietness_broken_up2 = stplanr::line_breakup(quietness_with_id_minimal, z = vertices)
remotes::install_github("saferactive/trafficalmr")
quietness_junctions = trafficalmr::osm_get_junctions(quietness_with_id_minimal)

nrow(quietness_with_id_minimal) # 35
nrow(quietness_broken_up) # 36
nrow(quietness_broken_up2) # 36


nrow(quietness_with_id_minimal)
sum(sf::st_length(quietness_with_id_minimal))
sum(sf::st_length(rnet_with_quietness1))

library(tmap)
tmap_mode("view")
qtm(rnet_buffer_with_quietness) +
  qtm(leeds_quietness_projected, lines.lwd = 9)

# Create minimal example
routes_r5r_buffer = routes_r5r_leeds |> 
  sf::st_transform(crs = 27700) |> 
  sf::st_buffer(dist = 5) |> 
  sf::st_transform(4326)

routes_r5r_buffer4 = routes_r5r_leeds |> 
  sf::st_transform(crs = 27700) |> 
  sf::st_buffer(dist = 4) |> 
  sf::st_transform(4326)

leeds_quietness_along_route = leeds_quietness[routes_r5r_buffer, ]
mapview::mapview(leeds_quietness_along_route, zcol = "id", lwd = 9) +
  mapview::mapview(routes_r5r_buffer)

leeds_quietness_intersection = sf::st_intersection(
  leeds_quietness,
  routes_r5r_buffer4
)

summary(leeds_quietness$quietness)
quietness_with_id2 = sf::st_join(
  leeds_quietness_intersection |> 
    select(quietness),
  routes_r5r_buffer,
  join = sf::st_within
)

quietness_with_id2$length = as.numeric(sf::st_length(quietness_with_id2))
quietness_with_id_minimal2 = quietness_with_id2 |> 
  filter(!is.na(id)) |> 
  filter(length > 10)
qtm(quietness_with_id_minimal2)
