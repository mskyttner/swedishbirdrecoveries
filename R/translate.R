#' Translate strings for display in user interface
#' @param field the name of the field in birdrecoveries_i18n,
#' defined in data-raw/translation.csv originally
#' @param lang the language iso3 string in lower caps, default "eng"
#' @return a vector of field names if called without arguments,
#' otherwise the string corresponding to the field name for the
#' specified language
#' @importFrom dplyr "%>%" filter select_
#' @examples
#'  fields <- i18n()
#' @export
#'
i18n <- function(field, lang = "eng") {

	birdrecoveries_18n <- data("birdrecoveries_i18n")

	if (missing(field) && missing(lang))
		return (birdrecoveries_i18n$colname)

	if (!(lang == "eng")) lang <- "swe"
	desc <- paste0("desc_", lang)

	res <-
		birdrecoveries_i18n %>%
		filter(colname == field) %>%
		select_(desc) %>% .[[desc]]

  if (length(res) == 0) res <- ""

		return (res)
}
