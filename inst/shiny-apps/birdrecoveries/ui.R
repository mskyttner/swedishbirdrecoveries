shinyUI(fluidPage(
  theme = shinythemes::shinytheme("spacelab"),
  tags$head(tags$link(rel="shortcut icon", href="favicon.ico")),
  #  titlePanel("Fågeltrender - Totaler"),
  sidebarLayout(
    sidebarPanel(
      img(src = "logo.png", width = 50),
      hr(),
      selectizeInput("name", label = "Urval av fågelarter:",
       choices = unique(birdrecoveries$name),
       multiple = TRUE,
       options = list(maxItems = 20, placeholder = "Välj namn")#,
      )

    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Tabell",
          helpText("Nuvarande urval:"),
          br(),
          DT::dataTableOutput("table")
        ),
        tabPanel("Källa",
          helpText("Ladda ned nuvarande data i CSV:"),
          fluidRow(p(class = "text-center",
            downloadButton("dl", label = "Hämta all data"))
          )
        )
      )
    )
  )
))
