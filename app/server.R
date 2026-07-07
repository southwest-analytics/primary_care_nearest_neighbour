## ╔════════════════════════════════════════╗
## ║ Server: Lightweight orchestration only ║
## ╚════════════════════════════════════════╝

server <- function(input, output, session) {

  # 0. Organisation level ----
  # ══════════════════════════
  observeEvent(input$selLevel, {
    
    df <- fnGetData(input$selLevel)
    
    ## Rebuild organisation list using existing Region + ICB
    if (!is.null(input$selICB) && input$selICB != "") {
      
      choices <- df %>%
        filter(ICB_CODE == input$selICB) %>%
        distinct(ORG_CODE, ORG_NAME) %>%
        mutate(LABEL = sprintf("[%s] - %s", ORG_CODE, ORG_NAME)) %>%
        arrange(ORG_NAME) %>%
        select(LABEL, ORG_CODE) %>%
        deframe()

      updateSelectInput(
        session, "selOrg",
        choices = choices,
        selected = choices[1]
      )
      
    } else {
      
      ## If ICB not selected yet, just clear org
      updateSelectInput(session, "selOrg", choices = character(0))
      
    }
    
  })
  
    
  # 1. Reactive: current dataset ----
  # ═════════════════════════════════
  rv_data <- reactive({
    fnGetData(level = input$selLevel)
  })
  
  
  
  # 2. Region to ICB selector ----
  # ══════════════════════════════
  observeEvent(input$selRegion, {
    
    df <- rv_data()
    
    updateSelectInput(
      session, "selICB",
      choices = df %>%
        filter(NHSER_CODE == input$selRegion) %>%
        distinct(ICB_CODE, ICB_NAME) %>%
        mutate(LABEL = sprintf("[%s] - %s", ICB_CODE, ICB_NAME)) %>%
        arrange(ICB_NAME) %>%
        select(LABEL, ICB_CODE) %>%
        deframe()
    )
  })

  # 3. ICB to Organisation selector ----
  # ════════════════════════════════════
  observeEvent(input$selICB, {
    
    df <- rv_data()
    
    updateSelectInput(
      session, "selOrg",
      choices = df %>%
        filter(ICB_CODE == input$selICB) %>%
        distinct(ORG_CODE, ORG_NAME) %>%
        mutate(LABEL = sprintf("[%s] - %s", ORG_CODE, ORG_NAME)) %>%
        arrange(ORG_NAME) %>%
        select(LABEL, ORG_CODE) %>%
        deframe()
    )
  })
  
  # 4. Variable selector ----
  # ═══════════════════════════════
  observe({
    var_choices <- if(input$selLevel=="Practice"){
      df_practice_metadata %>%
        filter(GROUP==input$selVarGrp) %>%
        pull(FIELD_NAME)
    } else {
      df_pcn_metadata %>%
        filter(GROUP==input$selVarGrp) %>%
        pull(FIELD_NAME)
    }
    
    updateSelectInput(
      session, "selVar",
      choices = var_choices
    )
  })

  # 5. Variable description ----
  # ════════════════════════════
  output$txtVarDesc <- renderText({
    if(!is.null(input$selVar)){
      if(input$selLevel=="Practice"){
        sprintf("<b>Variable Description</b><br>%s", 
                df_practice_metadata$DESCRIPTION[df_practice_metadata$FIELD_NAME==input$selVar])
      } else
      {
        sprintf("<b>Variable Description</b><br>%s", 
                df_pcn_metadata$DESCRIPTION[df_pcn_metadata$FIELD_NAME==input$selVar])
      }
    }
  })    
  
  # 6. Summary text ----
  # ════════════════════
  # output$summary_text <- renderText({
  #   
  #   req(input$selOrg, input$selLevel, input$selType, input$selVar)
  #   
  #   s <- fnGetPerformanceSummary(
  #     input$selOrg,
  #     input$selLevel,
  #     input$selType,
  #     input$selVar
  #   )
  #   
  #   paste0(
  #     "Out of 10 neighbours: ",
  #     s$higher, " higher, ",
  #     s$lower, " lower"
  #   )
  # })

  # 7. Comparison plot text ----
  # ════════════════════════════
  
  output$comparison_plot <- renderGirafe({
    
    req(input$selOrg, input$selLevel, input$selType, input$selVar)
    
    df <- fnGetComparisonData(
      org_code = input$selOrg, 
      level = input$selLevel, 
      type = input$selType, 
      var = input$selVar)
    
    short_desc <- if(input$selLevel=="Practice"){
      df_practice_metadata$SHORT_DESC[df_practice_metadata$FIELD_NAME==input$selVar]
    } else {
      df_pcn_metadata$SHORT_DESC[df_pcn_metadata$FIELD_NAME==input$selVar]
    }
    title_text <- sprintf("[%s] - %s\nNearest Neighbour Comparison Box Plot for Indicator\n[%s] %s",
                          df$ORG_CODE[df$ORG_CODE==input$selOrg], df$ORG_NAME[df$ORG_CODE==input$selOrg], 
                          input$selVar, short_desc)
    
    
    if(input$selLevel=="Practice"){
      var_type <- df_practice_metadata$TYPE[df_practice_metadata$FIELD_NAME==input$selVar]
    } else {
      var_type <- df_pcn_metadata$TYPE[df_pcn_metadata$FIELD_NAME==input$selVar]
    }

    df$LABEL <- NA
    
    if(var_type=="CUR"){
      scale_y <- scale_y_continuous(labels = function(x){sprintf("£%s", prettyNum(x, big.mark = ",", digits = 2, scientific = FALSE))})
      df$LABEL[df$GROUP != "National"] <- sprintf("<b>[%s] - %s</b><br>[%s]<br>%s = £%s",
                                                  df$ORG_CODE[df$GROUP != "National"], df$ORG_NAME[df$GROUP != "National"], 
                                                  input$selVar, short_desc,
                                                  prettyNum(df$VALUE[df$GROUP != "National"], big.mark = ",", digits = 2, scientific = FALSE))
    } else if(var_type=="PCT") {
      scale_y <- scale_y_continuous(labels = function(x){sprintf("%.2f%%", x * 100)})
      df$LABEL[df$GROUP != "National"] <- sprintf("<b>[%s] - %s</b><br>[%s]<br>%s = %.2f%%",
                                                  df$ORG_CODE[df$GROUP != "National"], df$ORG_NAME[df$GROUP != "National"], 
                                                  input$selVar, short_desc,
                                                  df$VALUE[df$GROUP != "National"] * 100)
    } else {
      scale_y <- scale_y_continuous(labels = function(x){sprintf("%s", prettyNum(x, big.mark = ",", digits = 1))})
      df$LABEL[df$GROUP != "National"] <- sprintf("<b>[%s] - %s</b><br>[%s]<br>%s = %s",
                                                  df$ORG_CODE[df$GROUP != "National"], df$ORG_NAME[df$GROUP != "National"], 
                                                  input$selVar, short_desc,
                                                  prettyNum(df$VALUE[df$GROUP != "National"], big.mark = ",", digits = 1))
    }

    plt <- ggplot() +
      geom_boxplot_interactive(
        data = df,
        aes(x = "", y = VALUE),
        fill = "#D9E3F0",
        colour = "#4A6FA5",
        width = 0.3,
        outlier.shape = NA
      ) +
      geom_point_interactive(
        data = df %>% filter(GROUP == "Origin"),
        aes(x = "", y = VALUE, tooltip = LABEL),
        colour = "#D7301F",
        size = 5
      ) +
      geom_jitter_interactive(
        data = df %>% filter(GROUP == "Neighbour"),
        aes(x = "", y = VALUE, tooltip = LABEL),
        width = 0.05,
        colour = "#2C7FB8",
        size = 2.5
      ) +
      theme_bw(base_size = 8) +
      theme(
        plot.title = element_text(hjust = 0.5),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
      )
    
    y_axis <- short_desc
    plt <- plt + labs(title = title_text, x = "", y = y_axis)

    # Get the ymin and ymax from the boxplot hinges (or the points)
    ylim_min <- min(ggplot_build(plt)$data[[1]]$ymin, df$VALUE[df$GROUP!="National"])
    ylim_max <- max(ggplot_build(plt)$data[[1]]$ymax, df$VALUE[df$GROUP!="National"])
    plt <- plt + coord_cartesian(ylim = c(ylim_min, ylim_max))
    
    plt <- plt + scale_y
    
    plt <- ggiraph::girafe(ggobj = plt, width_svg = 8)
    plt <- girafe_options(
      plt,
      opts_tooltip(
        css = "background-color: rgba(255,255,255,0.95); color: black; padding: 10px 12px;
        border-radius: 8px; font-size: 11px; font-family: Arial, Helvetica, sans-serif;
        box-shadow: 0px 2px 6px rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1);"))
    
    plt
  })
  
  # 8. Output map ----
  # ══════════════════
  
  output$map <- renderLeaflet({
    
    req(input$selOrg, input$selLevel, input$selType)
    
    df <- fnGetData(input$selLevel)
    
    nearest_neighbours <- fnGetNearestNeighbours(
      input$selOrg,
      input$selLevel,
      input$selType
    )
    
    ## Subset only what we need
    df_map <- df %>%
      filter(
        ORG_CODE == input$selOrg |
          ORG_CODE %in% nearest_neighbours
      ) %>%
      mutate(
        TYPE = case_when(
          ORG_CODE == input$selOrg     ~ "Origin",
          TRUE                         ~ "Neighbour"
        )
      )
    
    ## Convert to sf
    sf_map <- st_as_sf(
      df_map,
      coords = c("LONGITUDE", "LATITUDE"),
      crs = 4326,
      remove = FALSE
    )
    
    leaflet(sf_map) %>%
      addProviderTiles("CartoDB.Positron") %>%
      
      ## Neighbours
      addCircleMarkers(
        data = sf_map %>% filter(TYPE == "Neighbour"),
        radius = 6,
        fillColor = "#2C7FB8",
        fillOpacity = 0.8,
        stroke = FALSE,
        popup = ~paste0(
          "<b>[", ORG_CODE, "] - ", ORG_NAME, "</b><br>",
          "<b>Region:</b> ", NHSER_CODE, " - ", NHSER_NAME, "<br>",
          "<b>ICB:</b> ", ICB_CODE, " - ", gsub(" ICB", "", ICB_NAME), "<br>")
      ) %>%
      
      ## Origin (larger, standout)
      addCircleMarkers(
        data = sf_map %>% filter(TYPE == "Origin"),
        radius = 10,
        fillColor = "#D7301F",
        fillOpacity = 1,
        stroke = TRUE,
        color = "white",
        weight = 2,
        popup = ~paste0(
          "<b>[", ORG_CODE, "] - ", ORG_NAME, "</b><br>",
          "<b>Region:</b> ", NHSER_CODE, " - ", NHSER_NAME, "<br>",
          "<b>ICB:</b> ", ICB_CODE, " - ", gsub(" ICB", "", ICB_NAME), "<br>")
      ) %>%
      
      addControl(
        html = 'Source: Office for National Statistics licensed under the Open Government Licence v.3.0<br>Contains OS data © Crown copyright and database right [2026]',
        position = "bottomleft", layerId = NULL, className = "info legend"
      )
      
  })
  
  # 9. Output table ----
  # ════════════════════
  
  output$table <- renderUI({
    req(input$selOrg, input$selLevel, input$selType, input$selVar)

    df <- fnGetData(input$selLevel)

    nearest_neighbours <- fnGetNearestNeighbours(
      input$selOrg,
      input$selLevel,
      input$selType
    )
    
    
    df_table <- df %>%
      filter(
        ORG_CODE == input$selOrg |
          ORG_CODE %in% nearest_neighbours
      ) %>%
      mutate(
        TYPE = case_when(
          ORG_CODE == input$selOrg ~ "Origin",
          TRUE                     ~ "Neighbour"
        )
      ) %>%
      mutate(ORG_CODE = factor(ORG_CODE, levels = c(input$selOrg, nearest_neighbours))) %>%
      arrange(ORG_CODE) %>%
      select(TYPE, ORG_CODE, ORG_NAME, ORG_POSTCODE, ICB_NAME, NHSER_NAME, VALUE = all_of(input$selVar)) %>%
      mutate(STAT = NA, .before = "VALUE") %>%
      bind_rows(
        df %>% 
          semi_join(df %>% filter(ORG_CODE==input$selOrg), by = "ICB_CODE") %>%
          select(ICB_CODE, ICB_NAME, VALUE = all_of(input$selVar)) %>%
          group_by(ICB_CODE, ICB_NAME) %>%
          reframe(VALUE = quantile(VALUE, probs = c(0, .25, .5, .75, 1), na.rm = TRUE)) %>%
          ungroup() %>%
          rename(ORG_CODE = "ICB_CODE",
                 ORG_NAME = "ICB_NAME") %>%
          mutate(STAT = c("Min.", "Lower Quart.", "Median", "Upper Quart.", "Max."), .before = "VALUE") %>%
          mutate(TYPE = "Origin ICB", .before = 1)
      ) %>%
      bind_rows(
        df %>% 
          semi_join(df %>% filter(ORG_CODE==input$selOrg), by = "NHSER_CODE") %>%
          select(NHSER_CODE, NHSER_NAME, VALUE = all_of(input$selVar)) %>%
          group_by(NHSER_CODE, NHSER_NAME) %>%
          reframe(VALUE = quantile(VALUE, probs = c(0, .25, .5, .75, 1), na.rm = "TRUE")) %>%
          ungroup() %>%
          rename(ORG_CODE = "NHSER_CODE",
                 ORG_NAME = "NHSER_NAME") %>%
          mutate(STAT = c("Min.", "Lower Quart.", "Median", "Upper Quart.", "Max."), .before = "VALUE") %>%
          mutate(TYPE = "Origin Region", .before = 1)
      ) %>%
      bind_rows(
        df %>% 
          select(VALUE = all_of(input$selVar)) %>%
          reframe(VALUE = quantile(VALUE, probs = c(0, .25, .5, .75, 1), na.rm = "TRUE")) %>%
          ungroup() %>%
          mutate(ORG_CODE = "ENG", ORG_NAME = "ENGLAND", 
                 STAT = c("Min.", "Lower Quart.", "Median", "Upper Quart.", "Max."), .before = "VALUE") %>%
          mutate(TYPE = "Overall", .before = 1)
      )

    if(input$selLevel=="Practice"){
      var_type <- df_practice_metadata$TYPE[df_practice_metadata$FIELD_NAME==input$selVar]
    } else {
      var_type <- df_pcn_metadata$TYPE[df_pcn_metadata$FIELD_NAME==input$selVar]
    }
    
    if(var_type=="CUR"){
      df_table$VALUE <- sprintf("£%s", prettyNum(df_table$VALUE, big.mark = ",", digits = 2, scientific = FALSE))
    } else if(var_type=="PCT") {
      df_table$VALUE <- sprintf("%.2f%%", df_table$VALUE * 100)
    } else {
      df_table$VALUE <- sprintf("%s", prettyNum(df_table$VALUE, big.mark = ",", digits = 1))
    }
    
    flextable::flextable(data = df_table) %>% 
      autofit() %>%
      set_header_labels(TYPE = "Type",
                        ORG_CODE = "Code",
                        ORG_NAME = "Name",
                        ORG_POSTCODE = "Postcode",
                        ICB_NAME = "ICB",
                        NHSER_NAME = "Region",
                        STAT = "Statistic",
                        VALUE = "Value") %>%
      merge_v(j = 1:3) %>%
      vline(j = c(1, 6)) %>%
      hline(i = 1) %>%
      hline(i = 11) %>%
      hline(i = 16) %>%
      hline(i = 21) %>%
      htmltools_value()
    # flextable::flextable(data = data.frame(varA = c("A","B","C"), varB = c(1,2,3))) %>% htmltools_value()
    # datatable(
    #   df_table,
    #   options = list(pageLength = 26, scrollX = TRUE),
    #   rownames = FALSE
    # )
    
  })
  
  # 10. Toggle drop downs ----
  # ══════════════════════════
  observeEvent(
    input$tabPanel,
    {
      if(input$tabPanel=='Map'){
        shinyjs::show("sidebar_controls")
        shinyjs::hide(id = 'selVarGrp')
        shinyjs::hide(id = 'selVar')
        shinyjs::hide(id = 'txtVarDesc')
        shinyjs::hide(id = 'download_data')
      } else if(input$tabPanel=="Comparison"){
        shinyjs::show("sidebar_controls")
        shinyjs::show(id = 'selVarGrp')
        shinyjs::show(id = 'selVar')
        shinyjs::show(id = 'txtVarDesc')
        shinyjs::hide(id = 'download_data')
      } else if(input$tabPanel=="Table"){
        shinyjs::show("sidebar_controls")
        shinyjs::show(id = 'selVarGrp')
        shinyjs::show(id = 'selVar')
        shinyjs::show(id = 'txtVarDesc')
        shinyjs::show(id = 'download_data')
      } else if(input$tabPanel %in% c("Data Sources", "Methodology")){
        shinyjs::hide("sidebar_controls")
      }
    }
  )
  
  # 11. Download data ----
  # ══════════════════════
  output$download_data <- downloadHandler(
    
    filename = function() {
      paste0("nearest_neighbour_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".xlsx")
    },
    
    content = function(file) {
      nearest_neighbours <- fnGetNearestNeighbours(
        input$selOrg,
        input$selLevel,
        input$selType
      )
      
      df <- fnGetData(input$selLevel) %>%
        filter(
          ORG_CODE == input$selOrg |
            ORG_CODE %in% nearest_neighbours
        ) %>%
        mutate(
          TYPE = case_when(
            ORG_CODE == input$selOrg ~ "Origin",
            TRUE                     ~ "Neighbour"
          )
        ) %>%
        mutate(ORG_CODE = factor(ORG_CODE, levels = c(input$selOrg, nearest_neighbours))) %>%
        arrange(ORG_CODE)
      writexl::write_xlsx(df, file)
    }
  )
  
  # 12. Documentation tabs ----
  # ═══════════════════════════
  
  output$data <- renderUI({
    includeHTML("www/data_sources.html")
  })
  
  output$method <- renderUI({
    includeHTML("www/methodology.html")
  })

  # 99. Ensure clean exit ----
  # ══════════════════════════
  
  session$onSessionEnded(function(){
    stopApp()
  })
  
}