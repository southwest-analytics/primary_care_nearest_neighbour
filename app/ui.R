ui <- fluidPage(

  shinyjs::useShinyjs(),
  withMathJax(),
  
  tags$div(
    style = "
    background-color: #003A8F;
    padding: 10px 20px;
    display: flex;
    align-items: center;
    color: white;
  ",
    
    tags$a(
      href = "https://healthinnovationsouthwest.com/",
      target = "_blank",     
      ## Logo
      tags$img(
        src = "HISW_Logo_RGB_Negative.png",
        height = "50px",
        style = "margin-right: 20px;"
      ),
    ),
    
    ## App title
    tags$div(
      style = "font-size: 22px; font-weight: bold;",
      "Nearest Neighbour Comparison"
    )
  ),

  sidebarLayout(
    
    div(
      id = "sidebar_controls",

      sidebarPanel(
        
        radioButtons(
          "selLevel", "Level",
          choices = c("Practice", "PCN")
        ),
        
        selectInput("selRegion", "Region", choices = var_regions),
        selectInput("selICB", "ICB", choices = NULL),
        selectInput("selOrg", "Organisation", choices = NULL),
        
        hr(),
        
        selectInput("selType", "Comparison Group",
                    choices = c(
                      "National" = "ALL",
                      "Same Region" = "REGION",
                      "Same ICB" = "ICB"
                    )),
        
        selectInput("selVarGrp", "Variable Group", choices = var_groups),
        
        selectInput("selVar", "Variable", choices = NULL),
        
        htmlOutput("txtVarDesc"), 
        
        downloadButton(
          "download_data",
          "Download Comparison Data"
        )
      )
        
      
    ),
    
    mainPanel(
      
      tabsetPanel(id = "tabPanel",
        # Tab 1: Map
        # ──────────
        tabPanel("Map", leafletOutput("map", height = "75vh")),
        
        # Tab 2: Comparison
        # ─────────────────
        tabPanel("Comparison", 
                 girafeOutput("comparison_plot", height = "60vh")),
        
        # Tab 3: Table
        # ────────────
        tabPanel("Table", 
                 uiOutput("table")),

        # Tab 4: Data Sources
        # ───────────────────
        tabPanel(
          "Data Sources",
          div(
            class = "hisw-content",
            uiOutput("data")
          )
        ),
        
        # Tab 5: Methodology
        # ──────────────────
        tabPanel(
          "Methodology",
          div(
            class = "hisw-content",
            uiOutput("method")
          )
        )        

      )
    )
  )
)
