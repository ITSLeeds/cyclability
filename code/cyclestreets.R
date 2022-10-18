# get quitness from cyclestreets


quietness_shp = cyclestreets::ways(bb = leeds_smallarea, limit = 10000)

quietness_lts_osmtags = r5r_lts_osmtags %>%
  left_join(quietness_shp %>% 
              st_drop_geometry() %>%
              mutate(id = as.character(id)),
            by=c("osm_id" = "id"))


cor(x = quietness_lts_osmtags$bicycle_lts, y = quietness_lts_osmtags$quietness, use = "complete.obs")
# -0.115 ??
# one segment in r5r may correspond to multiple segments in cyclestreets   
                                                                               