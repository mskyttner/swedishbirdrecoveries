#!/usr/bin/Rscript

library(swedishbirdrecoveries)
library(readr)
library(dplyr)
library(devtools)

PUB_URL <- "http://fagel3.nrm.se/fagel/aterfynd/SQLDataExport.csv"
DEST <- paste0("/tmp/recoveries_", Sys.Date(), ".csv")
message("Downloading updated dataset from ", PUB_URL, " into ", DEST)

download.file(PUB_URL, destfile = DEST)

duration <- system.time(
	# need to skip first row, it says #TYPE System.Data.DataRow
	update_df <-
#		read_csv(DEST, skip = 1)
		read_csv(DEST, skip = 1, quote = "\"",
			locale = locale(decimal_mark = ","),
			col_types = "cccccccccDddcccccccDcccddccccccciiiiicccD")
)

# some crude validation rules

if (ncol(update_df) < 41)
	stop("Not performing update, missing cols, less than 41 cols in dataset")

if (nrow(update_df) < 0.9 * nrow(swedishbirdrecoveries::birdrecoveries_eng))
	stop("Not performing update, more than 10% of records are gone")

if (range(update_df$IDat)[2] < range(swedishbirdrecoveries::birdrecoveries_eng$modified_date)[2])
	stop("Not performing update, latest modified date lower than in package dataset")


# what does FKD with value "-REL" mean?
#View(birdrecoveries %>% slice(c(16487, 16488, 87761, 87762)))

#tmp <- update_df %>% arrange(desc(IDat)) %>% head(10)
#View(tmp)


message("Loaded data in ", duration[3], " s")
message("Columns are: ", paste(names(update_df), " "))
message("Number of records: ", nrow(update_df))
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
recovery_source,
modified_date"
))

names(update_df) <- new_colnames
swe_cols <- select_vars(new_colnames, ends_with("_swe"))
eng_cols <- select_vars(new_colnames, ends_with("_eng"))
swe_cols_new <- as.vector(gsub("_swe", "", swe_cols, fixed = TRUE))
eng_cols_new <- as.vector(gsub("_eng", "", eng_cols, fixed = TRUE))
names(swe_cols) <- swe_cols_new
names(eng_cols) <- eng_cols_new

birdrecoveries_eng <-
  update_df %>%
  select(everything(), -ends_with("swe")) %>%
  dplyr::rename_(.dots = eng_cols) %>%
	filter(!is.na(ringing_lon), !is.na(ringing_lat),
				 !is.na(recovery_lon), !is.na(recovery_lat))

#View(birdrecoveries_eng)

birdrecoveries_swe <-
  update_df %>%
  select(everything(), -ends_with("eng")) %>%
  dplyr::rename_(.dots = swe_cols) %>%
	filter(!is.na(ringing_lon), !is.na(ringing_lat),
				 !is.na(recovery_lon), !is.na(recovery_lat))

sbr <- system.file(package = "swedishbirdrecoveries")

devtools::use_data(birdrecoveries_eng,
	internal = FALSE, pkg = sbr, overwrite = TRUE)

devtools::use_data(birdrecoveries_swe,
	internal = FALSE, pkg = sbr, overwrite = TRUE)
