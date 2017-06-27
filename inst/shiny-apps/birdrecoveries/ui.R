library(leaflet)
library(DT)
library(shinydashboard)


dbHeader <- dashboardHeader(
	titleWidth = 450,
	title = "Återfynd - Swedish Bird Recoveries", disable = FALSE,
	tags$li(a(href = 'https://www.nrm.se/faktaomnaturenochrymden/djur/faglar/fagelringar.1289.html',
						img(src = "birds.png", height = 30, width = 30),
						title = "Ring!",
						style = "padding-top:10px; padding-bottom:10px;"),
					class = "dropdown"),
	tags$li(a(href = 'https://www.nrm.se/forskningochsamlingar/miljoforskningochovervakning/ringmarkningscentralen.214.html',
						img(src = 'logo.png', height = 30, width = 30),
						title = "Ringmärkingscentralen",
						style = "padding-top:10px; padding-bottom:10px;"),
					class = "dropdown"),
	tags$li(a(href = 'https://nrm.se',
						img(src = "nrm-logo-white.png", height = 30, width = 30),
						title = "Swedish Museum of Natural History / Naturhistoriska Riksmuseet",
						style = "padding-top:10px; padding-bottom:10px;"),
					class = "dropdown")
)



# shinyUI(fluidPage(
#   theme = shinythemes::shinytheme("spacelab"),
#   tags$head(tags$link(rel="shortcut icon", href="favicon.ico")),
#   #titlePanel("Swedish Bird Recoveries / Återfynd"),
#  	tags$style(type = "text/css", "#birdmap {height: calc(100vh - 110px) !important;}"),
#   sidebarLayout(
#     sidebarPanel(
#     	img(src = "logo.png", height = 50),
#     	img(src = "nrm-logo-white.png", height = 50),
#     	img(src = "birds.png", height = 50),
#     	hr(),
#       uiOutput("species"),
#       uiOutput("country"),
#       uiOutput("lats"),
#       uiOutput("lons"),
# #      uiOutput("source"),
# #    	flowLayout(
# #    		uiOutput("months"),
# #    		uiOutput("years")
# #    	),
#     	uiOutput("lang")
#     ),
#
#     mainPanel(
#     	uiOutput("mytabs")
#     )
#   )
# ))


body2 <- dashboardBody(
	tabItems(
		tabItem(
			tabName = 'menu1'
			, tags$a(
				id = "mydiv", href = "#", 'click me',
				onclick = 'Shiny.onInputChange("mydata", Math.random());')
		),
		tabItem(
			tabName = 'menu2'
			, uiOutput('birdmap')
		)
	)
)

dashBody <- dashboardBody(
	#tags$style(type = "text/css", "#birdmap {height: calc(100vh - 120px) !important;}"),
	tags$head(
	tags$style(type = "text/css", "#mapbox { height: 80vh !important; }"),
	tags$style(type = "text/css", "#birdmap { height: 75vh !important; }")),
#	tags$style(type = "text/css", "#tabset1 { height: 80vh !important; }"),
#	uiOutput("body_UI"),
	uiOutput("tab_box")
)

dashboardPage(
	dbHeader,
#	dashboardHeader(titleWidth = 450, title = "Återfynd - Swedish Bird Recoveries", disable = FALSE),
	dashboardSidebar(width = 450,
		uiOutput("lang"),
		hr(),
		#sidebarMenuOutput("menu_tabs_ui"),
		#hr(),
		flowLayout(
			uiOutput("species"),
			uiOutput("country")
		),
		hr(),
		flowLayout(
			uiOutput("months"),
			uiOutput("years")
		),
		hr(),
		flowLayout(
			uiOutput("lats"),
			uiOutput("lons")
		),
		hr(),
		flowLayout(
			uiOutput("source")
		)
	),
	dashBody
		#tags$style(type = "text/css", ".box-body {height:80vh !important;}"),
		# note the -180px below is a magic constant found through empirical iterations
		# with dashboardHeader, it is more approx
#tags$style(type = "text/css", "#birdmap {height: calc(100vh - 250px) !important;}"),
#		tags$style(type = "text/css", "#birdmap {height: calc(100vh - 180px) #!important;}"),
#		fluidRow(uiOutput("mytabs"))
#		fluidRow(
#			tabBox(
#				id = "tabset1", width = 12,
#				uiOutput("mytabitems")
#			)
#		)

#	box(uiOutput("birdmap"))


)
