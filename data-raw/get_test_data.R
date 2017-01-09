library(readxl)
library(readr)
library(dplyr)
library(devtools)

# Use Internet Archive or Fagel3?

PUB_URL <- paste0("https://archive.org/download/",
	"swedishbirdrecoveries/recoveries.xlsx")

download.file(PUB_URL, destfile = "/tmp/recoveries.xlsx")

duration <- system.time(
	birdrecoveries <- readxl::read_excel("/tmp/recoveries.xlsx")
)

message("Loaded data in ", duration[3], " s")
message("Columns are: ", paste(names(birdrecoveries), " "))

# recovery_type (2, 3) -> ("alive", "dead")
# what does recovery_coord_accu mean ?

new_colnames <- unlist(strsplit(split = ",\\s+", x =
"name_swe, name_eng, sciname, ringing_sex_code,
ringing_sex_swe, ringing_sex_eng,
ringing_age_code, ringing_age_swe, ringing_age_eng,
ringing_date, ringing_lat, ringing_lon,
ringing_country_swe, ringing_country_eng,
ringing_province_swe, ringing_province_eng,
ringing_majorplace, ringing_minorplace,
recovery_type, recovery_date, recovery_date_accu_code,
recovery_date_accu_swe, recovery_date_accu_eng,
recovery_lat, recovery_lon, recovery_coord_accu,
recovery_country_swe, recovery_country_eng,
recovery_province_swe, recovery_province_eng,
recovery_majorplace, recovery_minorplace,
distance, direction, days, hours,
recovery_code, recovery_details_swe, recovery_details_eng,
source"
))

names(birdrecoveries) <- new_colnames
swe_cols <- select_vars(new_colnames, ends_with("_swe"))
eng_cols <- select_vars(new_colnames, ends_with("_eng"))
swe_cols_new <- as.vector(gsub("_swe", "", swe_cols, fixed = TRUE))
eng_cols_new <- as.vector(gsub("_eng", "", eng_cols, fixed = TRUE))
names(swe_cols) <- swe_cols_new
names(eng_cols) <- eng_cols_new

birdrecoveries_eng <-
  birdrecoveries %>%
  select(everything(), -ends_with("swe")) %>%
  dplyr::rename_(.dots = eng_cols)

birdrecoveries_swe <-
  birdrecoveries %>%
  select(everything(), -ends_with("eng")) %>%
  dplyr::rename_(.dots = swe_cols)

translation <- function(csv = "data-raw/translation.csv") {
	if (!file.exists(csv)) {
		colname <- names(birdrecoveries_eng)
		translation <- data_frame(colname, desc_swe = NA, desc_eng = NA)
		readr::write_csv(translation, csv)
		message("Now please fill in colnames descriptions in eng and swe...")
	} else {
		translation <- readr::read_csv(csv)
	}
}

translation <- translation()

translation_colnames <- grep("ui_", translation$colname, fixed = TRUE, invert = TRUE, value = TRUE)
if (!dplyr::setequal(translation_colnames, names(birdrecoveries_eng))) {
	warning("Missing translations in data-raw/translation.csv! Pls fix!")
	dplyr::setdiff(translation_colnames, names(birdrecoveries_eng))
}

#grep("eng", deparse(substitute(birdrecoveries_eng)))

gen_dox_dataset_rows <- function(df, desc) {
  fields <- names(df)
  #desc <- translation$desc_swe
  #if (english) desc <- translation$desc_eng
  template <- "#'   \\item{%s}{%s}"
	res <- purrr::map2_chr(fields, desc,
		function(x, y) sprintf(template, x, y))
  #res <- sapply(cols, function(x) gsub("__COL__", x, template))
  out <- paste0(collapse = "\n", res)
  message("Paste this into your dataset dox")
  message("in R/refdata.r")
  header <- paste0(sep = "\n", "#' Dataset ", deparse(substitute(df)), "\n",
    "#'\n#' Date: ", Sys.Date(), "\n",
    paste0("#' @format A data frame [", nrow(df), " x ", ncol(df), "]", "\n"),
    "#' \\describe{  ")
  footer <- paste0("#'   ... \n#'   }\n#' @source \\url{http://}\n\"",
                   deparse(substitute(df)), "\"")
  message(header)
  message(out)
  message(footer)
}

i18n_colnames <- function(df, translation) {
	lookup <- dplyr::inner_join(translation,
		data_frame(colname = names(df)))
	return (lookup)
}


gen_dox_dataset_rows(birdrecoveries_eng,
	i18n_colnames(birdrecoveries_eng, translation)$desc_eng)

devtools::use_data(internal = FALSE, birdrecoveries_eng, overwrite = TRUE)

gen_dox_dataset_rows(birdrecoveries_swe,
	i18n_colnames(birdrecoveries_swe, translation)$desc_swe)

devtools::use_data(internal = FALSE, birdrecoveries_swe, overwrite = TRUE)

meta_translation <- c("Field", "Translation in Swedish",
											"Translation in English")

birdrecoveries_i18n <- translation
gen_dox_dataset_rows(birdrecoveries_i18n, meta_translation)
devtools::use_data(internal = FALSE, birdrecoveries_i18n, overwrite = TRUE)


# rename a column and resave
df_tmp <- birdrecoveries_swe
library(dplyr)
df_tmp
df_new <- df_tmp %>% rename(source = recovery_source)
birdrecoveries_swe <- df_new
library(devtools)
use_data(internal = FALSE, birdrecoveries_swe, overwrite = TRUE)


####################



# locations

library(dplyr)
library(swedishbirdrecoveries)
birds <- tbl_df(birdrecoveries_eng)

orig <- birds  %>%
  select(lon = ringing_lon, lat = ringing_lat,
         ringing_country, ringing_province,
         ringing_majorplace, ringing_minorplace) %>%
	filter(!is.na(lat) & !is.na(lon))

dest <- birds  %>%
  select(lon = recovery_lon, lat = recovery_lat,
         recovery_country, recovery_province,
         recovery_majorplace, recovery_minorplace) %>%
	filter(!is.na(lat) & !is.na(lon))



library(DT)
datatable(birds %>% head(10))


library(leaflet)

leaflet(dest %>% head(100)) %>% addTiles() %>%
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

o <- orig %>% head(4000)
d <- dest %>% head(4000)

linez <- make_lines(o, d)
slndf <- SpatialLinesDataFrame(linez, match.ID = FALSE, data = as.data.frame(d))

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




