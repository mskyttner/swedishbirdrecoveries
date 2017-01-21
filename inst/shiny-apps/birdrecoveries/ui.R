library(leaflet)
library(DT)
library(shinydashboard)

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


dashboardPage(
	dashboardHeader(titleWidth = 450, title = "Återfynd - Swedish Bird Recoveries", disable = FALSE),
	dashboardSidebar(width = 450,
		hr(),
		img(src = "logo.png", height = 50),
		img(src = "nrm-logo-white.png", height = 50),
		img(src = "birds.png", height = 50),
#		uiOutput("lang"),
		hr(),
		flowLayout(
	    uiOutput("species"),
	    uiOutput("country")
		),
#		hr(),
		flowLayout(
			uiOutput("months"),
			uiOutput("years")
		),
		hr()
#		flowLayout(
#			uiOutput("lats"),
#    	uiOutput("lons")
#		)
	),
	dashboardBody(
		#tags$style(type = "text/css", ".box-body {height:80vh !important;}"),
		# note the -180px below is a magic constant found through empirical iterations
		# with dashboardHeader, it is more approx
		tags$style(type = "text/css", "#birdmap {height: calc(100vh - 250px) !important;}"),
		uiOutput("mytabs")
	)
)
