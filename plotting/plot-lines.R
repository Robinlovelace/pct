source("case-studies/leeds.R")
source("case-studies/leeds-lines.R")

library("ggmap")
leeds <- spTransform(leeds, CRS("+init=epsg:4326"))
fleeds <- fortify(leeds)
p_leeds_lines <- ggplot() +
  geom_polygon(data = fleeds, aes(long, lat, group = group )) +
  geom_path(data = fleeds, aes(long, lat, group = group), color = "blue") +
  geom_segment(data = flow, aes(x = lon_origin, y = lat_origin,
    xend = lon_dest, yend = lat_dest, alpha = Bicycle), col = "white") +
  coord_map() +
  theme_nothing()
# saveRDS(p_leeds_lines, "figures/plp_leeds_lines.Rds")

# ggsave("private-data/figures/leeds-flow-bicycle.png")
