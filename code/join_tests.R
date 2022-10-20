library(tidyverse)

leeds_lts = readRDS("r5r/r5r_lts_osmtags.Rds")
leeds_quietness = sf::read_sf("cyclestreets/leeds_quietness.geojson")
mapview::mapview(leeds_quietness)

# Minimal example
leeds_quietness_1 = leeds_quietness |> 
  filter(id == "4371080")

leeds_minimal_quietness = leeds_quietness[leeds_quietness_1, ]
leeds_minimal_lts = leeds_lts[leeds_quietness_1, ]

nrow(leeds_minimal_quietness)
plot(leeds_minimal_quietness$geometry, col = "red", lwd = 5)
plot(leeds_minimal_lts$geometry, col = "blue", lwd = 2, add = TRUE)

# Join when we have IDs
leeds_minimal_lts_with_quietness = left_join(
  leeds_minimal_lts,
  leeds_minimal_quietness |>
    transmute(osm_id = as.character(id), quietness) |>
    sf::st_drop_geometry()
)
mapview::mapview(leeds_minimal_lts_with_quietness)

# Join when we do not have IDs
leeds_minimal_lts_no_id = leeds_minimal_lts |> 
  select(-osm_id)
# What's the average length of each segment?
summary(sf::st_length(leeds_minimal_lts_no_id))
summary(sf::st_length(leeds_minimal_quietness))

# Convert to project dataset
lts_no_id_projected = sf::st_transform(leeds_minimal_lts_no_id, crs = "EPSG:27700")
quietness_projected = sf::st_transform(leeds_minimal_quietness, crs = "EPSG:27700")
buffer_length = 1 # buffer width
# Buffer the dataset that is has larger average length
quietness_projected_buffer = sf::st_buffer(quietness_projected, dist = buffer_length)
mapview::mapview(quietness_projected_buffer)
lts_projected_new_id = sf::st_join(
  lts_no_id_projected,
  quietness_projected_buffer |> 
    select(id, quietness),
  join = sf::st_within
    )

lts_projected_new_id$id
mapview::mapview(quietness_projected_buffer) +
  mapview::mapview(lts_projected_new_id)


# Larger example
leeds_lts_with_quietness = left_join(
  leeds_lts,
  leeds_quietness |>
    transmute(osm_id = as.character(id), quietness) |>
    sf::st_drop_geometry()
) |> 
  tibble::as_tibble()
cor(leeds_lts_with_quietness$bicycle_lts, leeds_lts_with_quietness$quietness, use = "complete.obs")
leeds_lts$geom_text = sf::st_as_text(leeds_lts$geometry)
summary(duplicated(leeds_lts$geom_text))

# Without OSM ids
leeds_quietness_no_id = leeds_quietness |> select(-id)
leeds_quietness_new_id = sf::st_join(leeds_quietness_no_id, leeds_lts |> select(osm_id), join = sf::st_overlaps) 
head(leeds_quietness_new_id$osm_id)

# Next step: try with a buffer
sf::sf_use_s2(FALSE) # ? 


plot(leeds_quietness_new_id$geometry[1:9])
plot(leeds_quietness$geometry[1:9])
plot(leeds_quietness$id[1:9], as.integer(leeds_quietness_new_id$osm_id)[1:9])

#  Read-in routes
routes_r5r_leeds = sf::read_sf("routes_r5r_leeds.geojson")
mapview::mapview(routes_r5r_leeds)
summary(sf::st_length(routes_r5r_leeds))
  


rnet_r5r = stplanr::overline(routes_r5r_leeds, attrib = "distance")
rnet_r5r$id = seq(nrow(rnet_r5r))
nrow(rnet_r5r)
mapview::mapview(rnet_r5r)

rnet_buffer = rnet_r5r |> 
  sf::st_transform(crs = "EPSG:27700") |> 
  sf::st_buffer(dist = 5)
leeds_quietness_projected = leeds_quietness |> 
  sf::st_transform(crs = "EPSG:27700") 

# Joining the shorter segments, generates lots of duplicated geometries  
rnet_buffer_with_quietness = sf::st_join(
  rnet_buffer,
  leeds_quietness_projected |> 
    select(quietness),
  join = sf::st_contains
)

summary(duplicated(sf::st_as_text(rnet_buffer_with_quietness$geometry)))
rnet_with_quietness = rnet_buffer_with_quietness |> 
  group_by(distance) |> 
  summarise(quietness = mean(quietness, na.rm = TRUE))

# Joining data from the longer segments, generates few duplicated geometries
quietness_with_id = sf::st_join(
  leeds_quietness_projected |> 
    select(quietness),
  rnet_buffer |> select(id),
  join = sf::st_within
)
nrow(quietness_with_id)
nrow(leeds_quietness_projected)
summary(quietness_with_id$id)
quietness_summary = quietness_with_id |> 
  sf::st_drop_geometry() |> 
  group_by(id) |> 
  summarise(
    quietness_mean = mean(quietness, na.rm = TRUE),
    quietness_min = min(quietness, na.rm = TRUE)
    )
rnet_with_quietness1 = left_join(
  rnet_r5r,
  quietness_summary
)

summary(duplicated(sf::st_as_text(rnet_buffer_with_quietness$geometry)))
rnet_with_quietness = rnet_buffer_with_quietness |> 
  group_by(distance) |> 
  summarise(quietness = mean(quietness, na.rm = TRUE))

rnet_with_quietness1
rnet_with_quietness

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
