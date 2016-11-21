library(leaflet)
library(DT)
#library(shinydashboard)

shinyUI(fluidPage(
  theme = shinythemes::shinytheme("spacelab"),
  tags$head(tags$link(rel="shortcut icon", href="favicon.ico")),
  #titlePanel("Swedish Bird Recoveries / Återfynd"),
  tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
  sidebarLayout(
    sidebarPanel(
    	img(src = "nrm-logo.png", width = 50),
    	img(src = "logo.png", width = 50),
      hr(),
      uiOutput("species"),
      uiOutput("country"),
      uiOutput("lats"),
      uiOutput("lons"),
      uiOutput("source"),
      uiOutput("lang")
    ),

    mainPanel(
    	uiOutput("mytabs")
    )
  )
))
