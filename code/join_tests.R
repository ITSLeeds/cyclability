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

leeds_minimal_lts_with_quietness = left_join(
  leeds_minimal_lts,
  leeds_minimal_quietness |>
    transmute(osm_id = as.character(id), quietness) |>
    sf::st_drop_geometry()
)

mapview::mapview(leeds_minimal_lts_with_quietness)

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
rnet_r5r = stplanr::overline(routes_r5r_leeds, attrib = "distance")
nrow(rnet_r5r)
mapview::mapview(rnet_r5r)
