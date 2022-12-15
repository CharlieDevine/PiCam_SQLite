library(RSQLite)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(ggplot2)

# Get directory paths
setwd('../')
git.fp = getwd()
data.fp = paste(git.fp, 'Data', sep = '/')

# Connect to "PiCam_Summer2020.db" SQLite database
picam.db = dbConnect(RSQLite::SQLite(), paste(data.fp, 'PiCam_Summer2020.db', sep = '/'))

# Server
server = function(input, output, session) {
  output$GCCtimeseries = renderPlot(
    {
      d = dbGetQuery(
        conn = picam.db,
        statement = 
          "SELECT Dates_YYYYMMDD, HouseID, Plot, Winter, Summer, Green_Index_av
            FROM PiCam_VI_Outputs
            WHERE HouseID = ?
              AND Plot = ? ",
        params = list(input$HouseID,
                      input$Plot)
      )
      ggplot(data = d, aes(x = as.Date(Dates_YYYYMMDD), y = Green_Index_av)) +
        geom_line(size = 2) +
        ylim(c(0.3,0.35)) +
        theme_bw(base_size = 15) +
        labs(x = 'Day', y = 'GCC [%]') + 
        ggtitle(paste0(d$House, ' Plot', d$Plot, ' ', d$Winter, ' ', d$Summer)) +
        theme(axis.text.x = element_text(angle = 60, hjust = 1),
              legend.position = 'none')
    }
  )
}

# UI
ui = fluidPage(
  titlePanel('PiCam GCC SQLite Explorer'),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = 'HouseID',
        label = 'House ID',
        choices = c('House01','House02','House03','House04','House05'),
        selected = 'House01'
      ),
      br(),
      selectInput(
        inputId = 'Plot',
        label = 'Plot #',
        choices = c('01','02','03','04','05','06','07','08','09','10','11','12'),
        selected = '01'
      )
    ),
    mainPanel(
      plotOutput(
        outputId = 'GCCtimeseries'
      )
    )
  )
)

shiny::shinyApp(ui = ui, server = server)