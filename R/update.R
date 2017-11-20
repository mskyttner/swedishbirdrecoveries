
sbr_sqlite <- function() dplyr::src_sqlite(file.path(system.file(
		package = "swedishbirdrecoveries"), "extdata", "sbr.db"))

#' Get a history of updates made
#' @import dplyr
#' @export
update_log <- function() {
	sbr_sqlite() %>%
		tbl("updates") %>%
		collect %>% .$update_date %>%
		as.Date(origin = "1970-01-01")
}

#' Download dataset locally
#'
#' @importFrom readr read_csv locale
#' @importFrom dplyr select_vars filter
#' @importFrom utils download.file
#'
remote_dl <- function() {

	PUB_URL <- "http://fagel3.nrm.se/fagel/aterfynd/SQLDataExport.csv"
	DEST <- "/tmp/recoveries.csv"
	message("Downloading updated dataset from ",
		PUB_URL, " into ", DEST)
	#if (!file.exists(DEST))
	download.file(PUB_URL, DEST)

	update_df <- read_csv(DEST, skip = 1, quote = "\"",
		locale = locale(decimal_mark = ","),
		col_types = "cccccccccDddcccccccDcccddccccccciiiiicccD")

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

	birdrecoveries_swe <-
	  update_df %>%
	  select(everything(), -ends_with("eng")) %>%
	  dplyr::rename_(.dots = swe_cols) %>%
		filter(!is.na(ringing_lon), !is.na(ringing_lat),
					 !is.na(recovery_lon), !is.na(recovery_lat))

	TRANSLATION_DB <- file.path(system.file(
		package = "swedishbirdrecoveries"), "extdata", "translation.csv")

	birdrecoveries_i18n <- read_csv(TRANSLATION_DB)

	res <- list(birdrecoveries_swe, birdrecoveries_eng, birdrecoveries_i18n)
	names(res) <- c("birdrecoveries_swe", "birdrecoveries_eng", "birdrecoveries_i18n")
	return (res)
}

#' Update local db with dataset from remote, create if needed
#' @import dplyr
#' @importFrom dplyr src_sqlite copy_to db_insert_into
#' @importFrom tibble tibble
#' @export
update_data <- function(force = FALSE) {

	BIRDS_DB <- file.path(system.file(
		package = "swedishbirdrecoveries"), "extdata", "sbr.db")

	if (!file.exists(BIRDS_DB)) {
		message("Found no local db, creating using data from remote...")
		my_db <- src_sqlite(BIRDS_DB, create = TRUE)
	} else {
		my_db <- src_sqlite(BIRDS_DB)
	}

	# is there an update log?
	if (!"updates" %in% src_tbls(my_db)) {
		message("No updates table/log in local db, adding it")
		updates <- tibble(update_date = Sys.Date() - 1)
		copy_to(my_db, updates, "updates",
						temporary = FALSE, overwrite = TRUE)
	}

	# is the db up-to-date?
	latest_update <-
		my_db %>% tbl("updates") %>%
		summarize(latest = max(update_date)) %>%
		collect %>% .$latest %>%
		as.Date(origin = "1970-01-01")

	if (force == TRUE || Sys.Date() > latest_update) {
		message("Last update was", latest_update)
		message("Update needed, getting remote data...")
		res <- remote_dl()
		copy_to(my_db, res$birdrecoveries_eng, "birdrecoveries_eng",
			temporary = FALSE, overwrite = TRUE)
		copy_to(my_db, res$birdrecoveries_swe, "birdrecoveries_swe",
			temporary = FALSE, overwrite = TRUE)
		copy_to(my_db, res$birdrecoveries_i18n, "birdrecoveries_i18n",
			temporary = FALSE, overwrite = TRUE)
		message("Logging update with timestamp")
		today_df <- tibble(update_date = Sys.Date())
		db_insert_into(my_db$con, "updates", values = today_df)
		message("Done updating", BIRDS_DB)
	} else {
		message("No update needed, already up to date")
	}

}
