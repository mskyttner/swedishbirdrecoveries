shinyServer(function(input, output) {

  df <- reactive({
    df <- birdrecoveries

    if (length(input$name) > 0)
      df <- df %>% filter(name %in% input$name)

    return (df)
  })


  output$table <- DT::renderDataTable({
    df()
  }, options = list(lengthChange = FALSE, rownames = FALSE))

  output$dl <- downloadHandler("birdrecoveries.csv",
    contentType = "text/csv", content = function(file) {
    write.csv(birdrecoveries, file, row.names = FALSE)
  })

})
