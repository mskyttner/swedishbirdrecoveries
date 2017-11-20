library(DBI)
library(RSQLite)
library(dplyr)

BIRDS_DB <- file.path(.libPaths()[1],
 	"swedishbirdrecoveries", "extdata", "sbr.db")

con <- DBI::dbConnect(RSQLite::SQLite(), BIRDS_DB)

int_to_date <- function(x) as.Date(x, "1970-01-01")

birdrecoveries_i18n <- tibble::as_tibble(
 	DBI::dbReadTable(con, "birdrecoveries_i18n"))

DBI::dbDisconnect(con)
