library(devtools)
as.package("~/repos/swedishbirdrecoveries")
add_test_infrastructure()
use_data_raw()
use_github()
use_data()
use_news_md()
use_travis()
use_vignette("swedishbirdrecoveries-vignette")

load_all()
document()
clean_vignettes()
build_vignettes()

test()
build()
install()
check()

library(tools)
tools::checkRdaFiles("data")
tools::resaveRdaFiles("data")




library(networkD3)
library(dplyr)

taxon <- "knölsvan"
dyntaxa <-
  httr::GET(paste0("https://www.dyntaxa.se/?search=", URLencode(taxon)))
kn%C3%B6lsvan

library(taxize)
library(magrittr)

df <-
  taxize::eol_search("kanadagås") %>%
  unique()


library(maps)
library(geosphere)

df <- birdrecoveries

orig <- ggmap::geocode("Falsterbo")

ggmap::mutate_geocode()

bird <- df[3,]

# one hundred points along "crows path"
geosphere::gcIntermediate(
  n=100,  addStartEnd=TRUE,
  p1 = c(bird$lng, bird$lat),
  p2 = c(orig$lon, orig$lat))



birdrecoveries

# TODO:
# take network flows data and summarize
# node data w attribs
# edge data w counts

# below, geocode the coordinates

map("world", col = "green4", bg="#F5FFFA", lwd=0.05)
myposition <- c(-74, 40) # my position (where I am opening emails)

rlong <- c(75, 105, 135, - 10.2,  45.2, -30.4, 105, 35, -150,
           10.2,  145.2, 30.4) # received lat
rlat <- c(30, 43, 23, 12, 68, 55.6, 30, 43, 23, 12, 68, 55.6) # received long
nrecived <- c(4, 10, 5, 2, 4, 10, 4, 10, 5, 2, 4, 10 )     # number of email received
slong <- c(85, 85, 55, -40.2,  45.2, -30.4,45, 95, 55, 40.2,  55.2, 60.4 ) # send lat
slat <- c(10, 43, 13, 12, 68, 55.6,10, 43, 13, 12, 68, 55.6 ) # send long
nsend <- c(4, 10, 5, 2, 4, 10, 4, 10, 5, 2, 4, 10 )     # number of email send

mydf <- data.frame (rlat, rlong, nrecived, slat, slong, nsend)
for (i in 1: length (mydf) ) {
  send <- gcIntermediate(c(mydf[i,]$slong, mydf[i,]$slat), c(-74, 40),
                         n=100, addStartEnd=TRUE)
  lines(send, col = "blue", lwd = mydf[i, "nsend"]) # edited
  received <- gcIntermediate(c(mydf[i,]$rlong, mydf[i,]$rlat), c(-74, 40),
                             n=100,  addStartEnd=TRUE)
  lines(received , col = "red", lwd = mydf[i, "nrecived"])
}

# see also https://github.com/rafapereirabr/flow-map-in-r-ggplot


URL <- paste0(
  "https://cdn.rawgit.com/christophergandrud/networkD3/",
  "master/JSONdata/energy.json")

Energy <- jsonlite::fromJSON(URL)

nodes <- Energy$nodes
links <- Energy$links

tbl_df(nodes)
tbl_df(links)

# put locations in "nodes", with attributes such as groups
# (continents or higher level groupings, for example based on grids etc)

# calculate "from" and "to" values in terms of counts

sankeyNetwork(Links = links, Nodes = nodes, Source = "source",
  Target = "target", Value = "value", NodeID = "name",
  units = "TWh", fontSize = 12, nodeWidth = 30)


library(maps)
library(geosphere)
library(dplyr)
library(ggplot2)
library(rworldmap)
library(plyr)
library(data.table)
library(ggthemes)

worldMap <- getMap()
mapworld_df <- tbl_df(fortify(worldMap))

base <- "http://www.stanford.edu/~cengel/cgi-bin/anthrospace/wp-content/uploads/2012/03/"

# use read_csv?
read_df <- function(url)
  tbl_df(read.csv(paste0(base, url),
    as.is = TRUE, header = TRUE))

airports <- read_df("airports.csv")
flights <- read_df("PEK-openflights-export-2012-03-19.csv")

nodes <-
  tbl_df(airports) %>%
  select(IATA, longitude, latitude)

# count flights per route
# ie count edges between nodes
edge_count <-
  tbl_df(flights) %>%
  group_by(From, To) %>%
  count(From, To)

# add origin airport coords and dest airport coords
od <- left_join(edge_count, nodes, by = c("From" = "IATA") )
od <- left_join(od, nodes, by = c("To" = "IATA"))
od$id <-as.character(c(1:nrow(od)))

ggplot() +
  geom_polygon(data = mapworld_df,
    aes(long, lat, group = group),
    fill = "gray30") +
  geom_curve(data = od,
    aes(x = longitude.x, y = latitude.x, xend = longitude.y, yend = latitude.y, color = n), curvature = -0.3, arrow = arrow(length = unit(0.01, "npc"))) +
  scale_colour_distiller(palette = "Reds", name = "Frequency", guide = "colorbar") +
  coord_equal()





##### A more professional map ####
# Using shortest route between airports considering the spherical curvature of the planet
orig <- nodes %>% filter(IATA == "PEK") %>% select(longitude, latitude)
dest <- nodes %>% filter(IATA != "PEK") %>% select(longitude, latitude)

# distances between origin and destinations as spatial lines objects
routes <- gcIntermediate(orig, dest,
  n = 100, breakAtDateLine = FALSE, addStartEnd = TRUE, sp = TRUE)

# convert lines to data frame
ids <- data.frame(ID = 1:length(routes))
routes_df <- tbl_df(fortify(SpatialLinesDataFrame(routes, ids), region = "ID"))
gcircles <- left_join(routes_df, od, by = "id")

# recenter
center <- 115 # positive values only - US centered view is 260
gcircles$long.recenter <-
  ifelse(gcircles$long  < center - 180 , gcircles$long + 360, gcircles$long)

# shift coordinates to recenter worldmap
worldmap <- map_data("world")
worldmap$long.recenter <-
  ifelse(worldmap$long  < center - 180 , worldmap$long + 360, worldmap$long)

### Function to regroup split lines and polygons
# takes dataframe, column with long and unique group variable, returns df with added column named group.regroup
RegroupElements <- function(df, longcol, idcol){
  g <- rep(1, length(df[,longcol]))
  if (diff(range(df[,longcol])) > 300) {          # check if longitude within group differs more than 300 deg, ie if element was split
    d <- df[,longcol] > mean(range(df[,longcol])) # we use the mean to help us separate the extreme values
    g[!d] <- 1     # some marker for parts that stay in place (we cheat here a little, as we do not take into account concave polygons)
    g[d] <- 2      # parts that are moved
  }
  g <-  paste(df[, idcol], g, sep=".") # attach to id to create unique group variable for the dataset
  df$group.regroup <- g
  df
}

### Function to close regrouped polygons
# takes dataframe, checks if 1st and last longitude value are the same, if not, inserts first as last and reassigns order variable
ClosePolygons <- function(df, longcol, ordercol){
  if (df[1,longcol] != df[nrow(df),longcol]) {
    tmp <- df[1,]
    df <- rbind(df,tmp)
  }
  o <- c(1: nrow(df))  # rassign the order variable
  df[,ordercol] <- o
  df
}

# now regroup
gcircles.rg <- ddply(gcircles, .(id), RegroupElements, "long.recenter", "id")
worldmap.rg <- ddply(worldmap, .(group), RegroupElements, "long.recenter", "group")

# close polys
worldmap.cp <- ddply(worldmap.rg, .(group.regroup), ClosePolygons, "long.recenter", "order")  # use the new grouping var



# Flat map
ggplot() +
  geom_polygon(data=worldmap.cp, aes(long.recenter,lat,group=group.regroup), size = 0.2, fill="#f9f9f9", color = "grey65") +
  geom_line(data= gcircles.rg, aes(long.recenter,lat,group=group.regroup, color=freq), size=0.4, alpha= 0.5) +
  scale_colour_distiller(palette="Reds", name="Frequency", guide = "colorbar") +
  theme_map()+
  ylim(-60, 90) +
  coord_equal()


# Spherical Map
ggplot() +
  geom_polygon(data=worldmap.cp, aes(long.recenter,lat,group=group.regroup), size = 0.2, fill="#f9f9f9", color = "grey65") +
  geom_line(data= gcircles.rg, aes(long.recenter,lat,group=group.regroup, color=freq), size=0.4, alpha= 0.5) +
  scale_colour_distiller(palette="Reds", name="Frequency", guide = "colorbar") +
  # Spherical element
  scale_y_continuous(breaks = (-2:2) * 30) +
  scale_x_continuous(breaks = (-4:4) * 45) +
  coord_map("ortho", orientation=c(61, 90, 0))


# Any ideas on how to color the oceans ? :)


############

library(maptools)
library(cartogram)
library(rgdal)
data(wrld_simpl)

afr <- spTransform(wrld_simpl[wrld_simpl$REGION==2 & wrld_simpl$POP2005 > 0,],
                   CRS("+init=epsg:3395"))
plot(afr)
plot(nc_cartogram(afr, "POP2005"), add = TRUE, col = 'red')
nnc <- cartogram::cartogram(afr, weight = "POP2005")
plot(nnc)




library(rgdal)

# From https://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
#states <- readOGR("shp/cb_2013_us_state_20m.shp",
#                  layer = "cb_2013_us_state_20m", verbose = FALSE)

str(wrld_simpl)


# how to color "countries" with frequency
# of recaptured birds

states <- subset(wrld_simpl, wrld_simpl$NAME
 %in% unique(wrld_simpl$NAME))

leaflet(states) %>%
  addPolygons(
    stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5
#    color = ~colorQuantile("YlOrRd", states$AWATER)(AWATER)
  )


# Prognoser

- Random walk
- Exponential smoothing - latest ts points get more weight
- Regression analysis - simple regression cannot be used, only works for independent variables, need regression that works for dependent time series data
- ARIMA - använder ett slags medelvärde men tar in variation också

Hur bestämma rimligheten host progrnosen?

- skiljer det sig mycket?
- tror kunden den är rimlig :)
- stäm av mot historiska max-min-värden
- är den slumpmässig, finns det inget systematiskt mönster



