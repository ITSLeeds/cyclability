
leeds_smallarea = sf::read_sf("r5r/leeds_smallarea.geojson")
leeds_quietness = cyclestreets::ways(bb = leeds_smallarea, limit = 15000)
nrow(leeds_quietness)
mapview::mapview(leeds_quietness)
dir.create("cyclestreets")
sf::write_sf(leeds_quietness, "cyclestreets/leeds_quietness.geojson")
