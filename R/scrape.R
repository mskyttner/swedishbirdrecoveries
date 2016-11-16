#' Retrieve bird recovery data from Falsterbo Fågelstation
#' @param species the scientific name for a bird species
#' @return a data frame with recovery data
#' @import dplyr
#' @importFrom xml2 read_xml xml_children xml_attrs
#' @importFrom httr GET
#' @examples
#' df <- scrape_recoveries_falsterbo()
#' @export
#'
scrape_recoveries_falsterbo <- function(species = "ACNIS") {

  `%>%` <- dplyr::`%>%`

  base <- paste0("http://www.falsterbofagelstation.se/arkiv/",
    "aterfynd/min_genxml44.php")

  res <- GET(base, query = list(
    art = species,
    dist = 10,
    xtid = 99999,
    ntid = 0,
    fyears = paste(collapse = ", ", 1948:2016),
    fmonths = "alla",
    myears = "alla",
    mmonths = "alla",
    age = NULL,
    sex = "AND NUM_MSEX >= 0"))

  x <-
    read_xml(res) %>%
    xml_children() %>%
    xml_attrs()

  # convert named char vector to df
  nv2df <- function(x)
    data.frame(t(x), stringsAsFactors = FALSE)

  df <-
    purrr::map(x, nv2df) %>%
    bind_rows %>%
    mutate_each(funs(as.double), one_of("lat", "lng")) %>%
    mutate_each(funs(as.Date),  one_of("mdat", "fdat")) %>%
    mutate_each(funs(as.numeric),
      one_of("monad", "fkdkat", "riktn")) %>%
    mutate(dist = as.numeric(gsub(" ", "", dist)))

  return (tbl_df(df))
}

#' Retrieve species list from Falsterbo Fågelstation
#' @return a data frame with species names and codes
#' @import dplyr
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_attr html_text
#' @examples
#' df <- scrape_checklist_falsterbo()
#' @export
#'
scrape_checklist_falsterbo <- function() {

  # location of php page with species list data
  dimensions <- paste0("http://www.falsterbofagelstation.se/",
    "arkiv/aterfynd/fynduttag2.php")

  species_html <-
    read_html(dimensions) %>%
    html_nodes(xpath = "//select[@name='artlista']/option")

  # extract html option value (species id) and description
  desc <- species_html %>% html_attr("value")
  id <- species_html %>% html_text()

  taxa <-
    data_frame(id, desc) %>%
    filter(id != "Ingen art vald")

  return (tbl_df(taxa))
}

#' Retrieve species list from Ottenby Fågelstation
#' @return a data frame with species names and codes
#' @import dplyr
#' @importFrom httr GET
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom xml2 read_html
#' @examples
#' df <- scrape_checklist_ottenby()
#' @export
#'
scrape_checklist_ottenby <- function() {

  ottenby <- GET("http://www.access.ottenby.se/default.asp")

read_html
  html <-
    read_html(ottenby) %>%
    html_nodes(xpath = "//select[@name='art']/option")

  id <- html %>% html_attr("value")
  desc <- html %>% html_text()

  df <-
    data_frame(id, desc) %>%
    filter(desc != "Alla arter")

  return (tbl_df(df))
}

#' Retrieve bird recovery data from Ottenby Fågelstation
#' @return a data frame with recovery data
#' @import dplyr
#' @importFrom httr POST
#' @importFrom rvest html_text
#' @importFrom xml2 read_xml read_html
#' @examples
#' df <- scrape_recoveries_ottenby()
#' @export
#'
scrape_recoveries_ottenby <- function() {

  ottenby <- POST("http://www.access.ottenby.se/default.asp",
    query = list(
      lage = "enk",
      art = "",
      urvalsubmit = "G\u00f6r+urval"
    ))

  html <-
    read_html(ottenby, encoding = "ISO-8859-1") %>%
    html_text()

  grep_lines <- function(html, fixed) {
    lines <- unlist(strsplit(html, "\n"))
    res <- grep(fixed, lines, fixed = TRUE, value = TRUE)
    return (res)
  }

  html_popup <- grep_lines(html,
    "infodivtxt.innerHTML")
  html_coords <- grep_lines(html,
    "var posn = new google.maps.LatLng")

  parse_popup <- function(js) {
    re <- ".*infodivtxt\\.innerHTML = \"(.*?)\".*"
    html <- gsub(re, "\\1", js)
    txt <- read_html(html) %>% html_text()
    re <- paste0("Typ:(.*?)Art:(.*?)Omst\u00e4ndigheter:(.*?)",
      "M\u00e4rkdatum:(.*?)Fynddatum:(.*)")
    df <- data_frame(cat = gsub(re, "\\1", txt),
      species = gsub(re, "\\2", txt),
      context = gsub(re, "\\3", txt),
      ringing_date = gsub(re, "\\4", txt),
      recapture_date = gsub(re, "\\5", txt))
    return (df)
  }

  parse_coords <- function(js) {
    re <- ".*LatLng[(](.*?),\\s+(.*?)[)].*"
    lat <- gsub(re, "\\1", js)
    lon <- gsub(re, "\\2", js)
    df <- data_frame(lat, lon)
    return (df)
  }

  coords <- bind_rows(purrr::map(html_coords, parse_coords))
  popups <- bind_rows(purrr::map(html_popup, parse_popup))

  df <- bind_cols(coords, popups)

  res <- df %>%
    mutate_each(funs(as.numeric), one_of("lat", "lon")) %>%
    mutate_each(funs(as.Date), dplyr::contains("date")) %>%
    select(lon, lat, everything())

  return (res)
}

#' Retrieve species list from Norway, Stavanger
#' @return a data frame
#' @import dplyr
#' @importFrom httr GET
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_attr html_text
#' @examples
#' df <- scrape_checklist_norway()
#' @export
#'
scrape_checklist_norway <- function() {

  base <- "http://must.ringmerking.no/kart.asp"

  species_html <- GET(url = base, query = list(
    pxmode = "HENT1",
    rekkefolge = "AMFT",
    pxMerkeSted = NULL,
    pxFunnSted = NULL,
    pxArtNr = NULL,
    pxlang = "ENG"
  ))

  species <-
    read_html(species_html) %>%
    html_nodes(xpath = "//img") %>%
    html_attr("src")

  re <- ".*KT=(.*?)[&]ANT=(.*)"
  pairs <- grep(re, species, value = TRUE)
  desc <- gsub(re, "\\1", pairs)
  id <- gsub(re, "\\2", pairs)

  df <-
    data_frame(desc, id) %>%
    mutate(num = as.numeric(id)) %>%
    filter(!is.na(num)) %>%
    select(-num) %>%
    arrange(id)

  return (df)
}

#' Retrieve bird recovery data from Norway (Stavanger)
#' @param species_id the species id for a bird species
#' @return a data frame with recovery data
#' @import dplyr
#' @importFrom xml2 read_html
#' @importFrom httr GET
#' @importFrom rvest html_text
#' @examples
#' df <- scrape_recoveries_norway()
#' @export
#'
scrape_recoveries_norway <- function(species_id = 01580) {

  map <- GET("http://must.ringmerking.no/viskartmust.asp",
    query = list(
      pxMerkeSted = "ALL",
      rekkefolge = "AMFT",
      pxFunnSted = "ALL",
      pxArtNr = 01580,
      pxTidsrom = 4)
  )

  html <-
    read_html(map) %>%
    html_text()

  # quirky scrape of JS with ...
  #var contentString1
  #var marker1

  contentString <-
"Pink-footed Goose: NOS ....291997
  Merkeinfo: 30.07 200 GIPSDALEN
  Funninfo: 09.12 2007 Houtave, Loweg-Z
  3074 km
  132 dager/days
  [coordinate pair also available...]"
  message(contentString)
  message("\n... or using English: ...\n")
  message("lon, lat, species, ringing_date, recapture_date, dist_km, age_days")
}
