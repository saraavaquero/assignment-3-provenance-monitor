library(shiny)
library(mongolite)
library(DT)
library(jsonlite)

# Connect to MongoDB database containing provenance logs
db <- mongo(
  collection = "provenance_logs",
  db = "genomic_provenance_db",
  url = "mongodb://localhost:27017"
)

ui <- fluidPage(
  # Dashboard title
  titlePanel(
    div(
      style = "background-color:#2c7fb8; color:white; padding:15px; border-radius:5px;",
      "Genomic Provenance Monitor"
    )
  ),
  sidebarLayout(
    sidebarPanel(
      # Filtering options for data exploration
      style = "background-color:#f0f6fc; border-radius:5px;",
      h4("Filters"),
      selectInput("node","Execution Node:",choices=c("All")),
      selectInput("status","Integrity Status:",choices=c("All","OK","FAIL"))
    ),
    mainPanel(
      # Interactive table displaying processed records
      h3(div(style="color:#2c7fb8;","Provenance Records")),
      DTOutput("table"),
      hr(),
      # Detailed JSON view of selected record
      h3(div(style="color:#2c7fb8;","Full Provenance Schema")),
      verbatimTextOutput("json_output")
    )
  )
)

server <- function(input, output, session) {

  # Retrieve data and derive integrity indicators
  data <- reactive({
    raw <- db$find()

    raw$sha256 <- sapply(raw$generated,function(x){
      x$value[x$label=="Verificació SHA256"]
    })
    raw$seqfu <- sapply(raw$generated,function(x){
      x$value[x$label=="Verificació Seqfu"]
    })

    raw$size_bytes <- sapply(raw$generated,function(x){
      x$totalSizeBytes[x$label=="FASTQ Files"]
    })
    raw$category <- sapply(raw$generated,function(x){
      x$category[x$label=="FASTQ Files"]
    })

    # Simulate integrity status classification (OK vs FAIL)
    raw$sha_status <- ifelse(grepl("ERROR",raw$sha256),"FAIL","OK")
    raw$seqfu_status <- ifelse(grepl("ERROR",raw$seqfu),"FAIL","OK")

    raw
  })

  # Dynamically populate execution node filter
  observe({
    nodes <- unique(data()$executionNode)
    updateSelectInput(session,"node",choices=c("All",nodes))
  })

  # Apply user-defined filters to dataset
  filtered_data <- reactive({
    df <- data()

    if(input$node!="All"){
      df <- df[df$executionNode==input$node,]
    }
    if(input$status=="OK"){
      df <- df[df$sha_status=="OK"&df$seqfu_status=="OK",]
    }
    if(input$status=="FAIL"){
      df <- df[df$sha_status=="FAIL"|df$seqfu_status=="FAIL",]
    }

    df
  })

  # Render interactive data table
  output$table <- renderDT({
    table <- filtered_data()[,c(
      "label",
      "startTime",
      "endTime",
      "executionNode",
      "category",
      "size_bytes",
      "sha_status",
      "seqfu_status"
    )]
    datatable(table,selection="single",options=list(pageLength=10,scrollX=TRUE))
  })

  # Display full provenance JSON of selected row
  output$json_output <- renderPrint({
    req(input$table_rows_selected)
    selected <- filtered_data()[input$table_rows_selected,]
    toJSON(selected,pretty=TRUE,auto_unbox=TRUE)
  })
}

shinyApp(ui=ui,server=server)