library(readxl)
library(dplyr)

# här skulle vi vilja läsa från en publik url
birdrecoveries <- read_excel("data-raw/recoveries.xlsx")

old_col_names <- paste0(collapse = ", ", names(birdrecoveries))
message(old_col_names)

new_col_names <- unlist(strsplit(split = ",\\s+", x =
"name_swe, name_eng, sciname,
ringing_sex_code, ringing_sex_swe, ringing_sex_eng,
ringing_age_code, ringing_age_swe, ringing_age_eng,
ringing_date,
ringing_lat, ringing_lon,
ringing_country_swe, ringing_country_eng,
ringing_province_swe, ringing_province_eng,
ringing_majorregion, ringing_minorregion,
ringing_accu2,
recovery_date, recovery_accu_code, recovery_accu_swe, recovery_accu_eng, recovery_lat, recovery_lon,
recovery_accu2,
recovery_country_swe, recovery_country_eng,
recovery_province_swe, recovery_province_eng,
recovery_majorregion, recovery_minorregion,
distance, direction, days, hours,
recovery_code, recovery_det_swe, recovery_det_eng"
))

col_translation <- data_frame(new_col_names, names(birdrecoveries))
col_translation

names(birdrecoveries) <- new_col_names

swe_cols_old <- select_vars(names(birdrecoveries), ends_with("_swe"))
eng_cols_old <- select_vars(names(birdrecoveries), ends_with("_eng"))

swe_cols_new <- as.vector(gsub("_swe", "", swe_cols_old, fixed = TRUE))
eng_cols_new <- as.vector(gsub("_eng", "", eng_cols_old, fixed = TRUE))

eng_cols <- eng_cols_old
names(eng_cols) <- eng_cols_new

swe_cols <- swe_cols_old
names(swe_cols) <- swe_cols_new

birdrecoveries_eng <-
  birdrecoveries %>%
  select(everything(), -ends_with("swe")) %>%
  dplyr::rename_(.dots = eng_cols)

birdrecoveries_swe <-
  birdrecoveries %>%
  select(everything(), -ends_with("eng")) %>%
  dplyr::rename_(.dots = swe_cols)

use_data(birdrecoveries_swe)
use_data(birdrecoveries_eng)
birdrecoveries <- birdrecoveries_eng

use_data(birdrecoveries)









# locations

birds <- tbl_df(birdrecoveries_eng)

orig <- birds  %>%
  select(lon = ringing_lon, lat = ringing_lat,
         ringing_country, ringing_province,
         ringing_majorregion, ringing_minorregion)

dest <- birds  %>%
  select(lon = recovery_lon, lat = recovery_lat,
         recovery_country, recovery_province,
         recovery_majorregion, recovery_minorregion)



library(DT)
datatable(birds %>% head(10))


library(leaflet)

df <- birds %>% head(100) %>%
  select(latitude = ringing_lat,
         longitude = ringing_lon)

leaflet(df) %>% addTiles() %>%
  addCircleMarkers(
    radius = 4,
    stroke = TRUE, fillOpacity = 0.4
  )

make_lines <- function(orig, dest) {

  lines <- map2(dest$lon, dest$lat, function(x, y)
    sp::Line(cbind(c(orig$lon, x), c(orig$lat, y))))

  ids <- paste0("a", 1:length(lines))

  linez <- map2(lines, ids, function(x, y)
    sp::Lines(slinelist = x, ID = y))

  #rbind.SpatialLines(linezz, makeUniqueIDs = TRUE)
  linezz <- sp::SpatialLines(linez, proj4string = CRS("+init=epsg:4326"))
  return (linezz)
}

library(sp)
library(purrr)

library(sp)
library(mapview)

linez <- make_lines(orig, dest)
slndf <- SpatialLinesDataFrame(linez, match.ID = FALSE, data = as.data.frame(dest))

## display data
#mapview(slndf, zcol = "group", color = slndf@data$col)
mapview(head(slndf, 100))



lmap <-
  leaflet(data = birds) %>%
  addProviderTiles("OpenStreetMap.BlackAndWhite") %>%
  #  addMarkers(~lon, ~lat, popup = ~as.character(dgr)) %>%
  addPolylines(data = head(linez, 100)) %>%
  addCircleMarkers(data = dest,
    radius = 2,
    stroke = FALSE, fillOpacity = 0.5
  )

lmap

#llmap <- map(lines, function(x) lmap %>% addPolylines(data = x))

lmap




