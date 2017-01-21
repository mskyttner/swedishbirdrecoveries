library(lubridate)
# deploy to shiny in root context
#ln -s /usr/local/lib/R/site-library/swedishbirdrecoveries/shiny-apps/birdrecoveries/* .
library(swedishbirdrecoveries)

shinyServer(function(input, output) {

  #sex <- birds %>% distinct(ringing_sex) %>% .$ringing_sex
  #age <- birds %>% distinct(ringing_age) %>% .$ringing_age
  #code <- birds %>% distinct(recovery_code) %>% .$recovery_code
  cmin <- function(x) floor(min(x, na.rm = TRUE))
  cmax <- function(x) ceiling(max(x, na.rm = TRUE))

  df <- reactive({
    df <- birds()
    if (length(input$species) > 0)
      df <- df %>% filter(name %in% input$species)
    if (length(input$source) > 0)
      df <- df %>% filter(source %in% input$source)
    if (length(input$lats) > 0)
      df <- df %>% filter(recovery_lat >= input$lats[1],
                          recovery_lat <= input$lats[2])
    if (length(input$lons) > 0)
      df <- df %>% filter(recovery_lon >= input$lons[1],
                          recovery_lon <= input$lons[2])
    if (length(input$country) > 0)
      df <- df %>% filter(recovery_country %in% input$country)

    if (length(input$months) > 0)
    	df <- df %>% filter(month.name[month(recovery_date)] %in% input$months)

    if (length(input$years) > 0)
    	df <- df %>% filter(year(recovery_date) %in% input$years)

    hits <- nrow(df)
    status_swe <- paste0("Nuvarande urval ", hits,
			" (visar max 4000 av de senaste återfynden)")
    status_eng <- paste0("Current selection ", hits,
			" (displaying max 4000 of the most recent recoveries)")
    status <- status_eng
    if (lang() == "swe") status <- status_swe

    df <- df %>% arrange(desc(recovery_date)) %>% head(4000)
    res <- list(status = status, df = df)

#    res <- list(df = df)
    return (res)
  })

  lang <- reactive({
  	if (length(input$lang) > 0) {
  		if (input$lang == "Svenska") return ("swe")
  		if (input$lang == "English") return ("eng")
  	}
  	return ("eng")
	})

  birds <- reactive({
  		get(paste0("birdrecoveries_", lang()))
  })

  output$lang <- renderUI({
  	radioButtons(inputId = "lang", inline = TRUE,
		 label = NULL,
		 choices = c("English", "Svenska"), selected = "English")
  })

  output$species <- renderUI({
    species <- birds() %>% distinct(name) %>% arrange(name) %>% .$name
    sciname <- birds() %>% distinct(sciname) %>% .$sciname
    if (is.null(species)) return()
    default_species <-
    	birds() %>% filter(sciname == "Erithacus rubecula") %>%
    	select(name) %>% distinct %>% .$name
    selectizeInput("species", label = i18n("name", lang()),
      choices = species, selected = default_species,
      multiple = TRUE,
      options = list(maxItems = 20)#,
    )
  })

  output$source <- renderUI({
    source <- birds() %>% distinct(source) %>% .$source
    if (is.null(source)) return()
    selectizeInput("source", label = i18n("source", lang()),
      choices = source, multiple = TRUE,
      options = list(maxItems = 20)#,
    )
  })

  output$country <- renderUI({
    country <- birds() %>% distinct(recovery_country) %>% .$recovery_country
    if (is.null(country)) return()
    selectizeInput("country", label = i18n("recovery_country", lang()),
      choices = country, multiple = TRUE,
      options = list(maxItems = 20)#,
    )

  })

  output$months <- renderUI({
  	selectizeInput("months", label = i18n("ui_recovery_month", lang()),
  		choices = month.name, multiple = TRUE,
  		options = list(maxItems = 20))
  })
	output$years <- renderUI({
		y <- sort(unique(year(birdrecoveries_eng$recovery_date)), decreasing = TRUE)
		selectizeInput("years", label = i18n("ui_recovery_year", lang()),
			choices = y, multiple = TRUE,
			options = list(maxItems = 20))
	})

  output$lats <- renderUI({
    lat_min <- cmin(birds()$recovery_lat)
    lat_max <- cmax(birds()$recovery_lat)
    sliderInput("lats", i18n("recovery_lat", lang()), lat_min, lat_max,
                value = c(lat_min, lat_max), step = 1)
  })

  output$lons <- renderUI({
    lon_min <- cmin(birds()$recovery_lon)
    lon_max <- cmax(birds()$recovery_lon)
    sliderInput("lons", i18n("recovery_lon", lang()), lon_min, lon_max,
                value = c(lon_min, lon_max), step = 1)
  })

  output$birdmap <- renderLeaflet({
    out <- df()$df
    popup_content <- #htmltools::htmlEscape(
      paste(sep = "",
      "<b>", i18n("name", lang()), ":</b> ", out$name, "<br/>",
      "<b>", i18n("recovery_details", lang()), ":</b> ", out$recovery_details, "<br/>",
      "<b>", i18n("ringing_date", lang()), ":</b> ", out$ringing_date, "<br/>",
      " (", out$ringing_majorplace, ", ", out$ringing_minorplace, ")", "<br/>",
      "<b>", i18n("recovery_date", lang()), ":</b> ", out$recovery_date, "<br/>",
      " (", out$recovery_majorplace, ", ", out$recovery_minorplace, ")", "<br/>",
      "<br/>"
      )

    map <-
    	leaflet(data = out) %>%
      addProviderTiles("OpenStreetMap.BlackAndWhite", group = "Gray") %>%
#      addProviderTiles("Stamen.TonerLite", group = "Black & White") %>%
      #  addMarkers(~longitude, ~latitude, popup = ~as.character(dgr), group = "Individual") %>%
      addMarkers(~recovery_lon, ~recovery_lat, popup = popup_content,
                 clusterOptions = markerClusterOptions(), group = "Clustered") #%>%
#      addLayersControl(
#        baseGroups = c("Gray", "Black & White"),
        #    overlayGroups = c("Individual", "Clustered"),
#        options = layersControlOptions(collapsed = FALSE)
#      )

		#map$height <- "100%"
		#map$sizingPolicy$defaultHeight <- "100%"
		#message(str(map))
		map
  })

  output$table <- DT::renderDataTable({
    out <- df()$df
    headings <- purrr::map_chr(names(out),
	 		function(x) i18n(x, lang()))
    names(out) <- headings
    out
  }, options = list(pageLength = 5, lengthChange = FALSE, rownames = FALSE))

  output$dl <- downloadHandler("birdrecoveries.csv",
    contentType = "text/csv", content = function(file) {
    write.csv(df()$df, file, row.names = FALSE)
  })

  output$mytabs <- renderUI({
  	myTabs <- list(
	  	tabPanel(title = i18n("ui_tab_map_label", lang()),
#				helpText(i18n("ui_tab_map_help", lang())),
				helpText(df()$status),
				br(),
				#leafletOutput("birdmap")
				leafletOutput("birdmap", width = "100%", height = "100%")
	  	)  #,
	#   	tabPanel(i18n("ui_tab_table_label", lang()),
	# 			helpText(i18n("ui_tab_table_help", lang())),
	# 			br(),
	# 			dataTableOutput("table")
	#   	),
	#   	tabPanel(i18n("ui_tab_download_label", lang()),
	# 			helpText(i18n("ui_tab_download_help", lang())),
	# 			fluidRow(p(class = "text-center",
	# 				downloadButton("dl", label = i18n("ui_tab_download_help", lang())))
	# 			)
	#   	)
  	)
  	do.call(tabsetPanel, myTabs)
  })
})
