library(shiny)
library(shinydashboard)
library(DT)
library('MSstats', warn.conflicts = F, quietly = T, verbose = F)
library(reticulate)
library(pheatmap)
library(rhandsontable)
library(shinyjs)
library(shinyWidgets)
library(proteus)
library(ggplot2)

# Source getPlots functions
source("app/getPlots.R")
source("app/getSelector.R")


ui <- dashboardPage(
    dashboardHeader(title = "pQuantR"),
    dashboardSidebar(
        #useShinyjs(),
        
        # fileinput side bar menu
        conditionalPanel(condition = "input.main_tabs == 'fileinput_condition'",
                         h5('Note: this shiny app ...'),
                         tags$hr(), 
                         
                         # file selection box
                         fileInput('csvFile', 'Choose a \'out.csv\' file', multiple = FALSE, 
                                   accept=c('text/csv', 'text/comma-separated-values,text/plain')), # CSV text file
                         br(),
                         
                         helpText('Note: \'.mzTab\' is ... ')
                         ),
        
        
        # default method sidebar
        conditionalPanel(condition = "input.main_tabs == 'default_method_condition'",
                         h5('Note: Default method uses MSstats'),
                         h5('and pheatmap.'),
                         br(),
                         sidebarMenu(
                                # volcano sidebar
                               menuItem("Volcano plot",
                                         #tabName = 'default_method_volcano_show',
                                         br(),
                                         helpText('Please wait a second until the'),
                                         helpText('\"Options\" appear, then click'),
                                         helpText('\"Render Plot\".'),
                                         uiOutput('default_method_volcano_selector'),
                                         br(),
                                         actionButton(inputId = "default_method_volcano_Render",
                                                      label = "Render Plot",
                                                      icon = icon("play-circle"),
                                                      style ="display: block; margin: 0 auto; width: 200px;color: black;"
                                         ),
                                         br()
                                ),
                                
                                # heatmap sidebar
                               menuItem("Heatmap",
                                         #tabName = 'default_method_heatmap_show',
                                         br(),
                                         actionButton(inputId = "default_method_heatmap_Render",
                                                      label = "Render Plot",
                                                      icon = icon("play-circle"),
                                                      style ="display: block; margin: 0 auto; width: 200px;color: black;"
                                         ),
                                         br()
                                ),
                                
                                # qc sidebar
                               menuItem("QC plot",
                                         #tabName = 'default_method_qc_show',
                                         br(),
                                         helpText('Please wait a second until the'),
                                         helpText('\"Options\" appear, then click'),
                                         helpText('\"Render Plot\".'),
                                         uiOutput('default_method_qc_selector'),
                                         br(),
                                         actionButton(inputId = "default_method_qc_Render",
                                                      label = "Render Plot",
                                                      icon = icon("play-circle"),
                                                      style ="display: block; margin: 0 auto; width: 200px;color: black;"
                                         ),
                                         br()
                                )
                         )
        ),
  
        
        # proteus method sidebar
        conditionalPanel(condition = "input.main_tabs == 'proteus_condition'",
                         sidebarMenu(
                              menuItem("Data handling",
                                    helpText('Click to convert \'out.csv\' to a'),
                                    helpText('Proteus-compliant input format.'),
                                    br(),
                                    helpText('Make sure you have \'out_mztab.csv\''),
                                    helpText('in your data file folder.'),
                                    actionButton(inputId = "proteus_method_start_Render",
                                                 label = "Start",
                                                 icon = icon("play-circle"),
                                                 width = 200),
                                    br()
                              ),
                              menuItem("Assign metadata",
                                    div(style = "text-align:center", "Click to render annotation table"),
                                    actionButton(inputId = "start_anno",
                                               label = "Start",
                                               icon = icon("play-circle"),
                                               width = 200),
                                    br(),
                                    div(style = "text-align:center", "Your input in the second table",
                                      br(), "will be used for stastical",
                                      br(), "comparisons.",
                                      br(),br(), "Example:"),
                                    img(src = 'annotation_example.png', width = '100%'),
                                    div(style = "text-align:center", "once done renaming press",
                                      br(), "\'submit\' to lock in the annotation"),
                                    actionButton(inputId = "submit_anno",
                                               label = ">  Submit",
                                               width = 200),
                                    br(),br(),
                                    
                                    actionButton(inputId = "annoReset",
                                                 label = "Reset annotation",
                                                 width = 200,
                                                 icon = icon("redo"))
                             ),
                             menuItem("Normalization",
                                    br(),
                                    selectInput("proteus_normalizaiton_select",
                                                "Choose a norm parameter",
                                                list("Not normalized" = "Not normalized",
                                                     "Median normalization" = "Median normalization",
                                                     "Quantile normalization" = "Quantile normalization"
                                                ),
                                                selected = "Median normalization"
                                    ),
                                    br(),
                                    actionButton(inputId = "proteus_normalizaiton_Render",
                                                 label = "Render Plot",
                                                 icon = icon("play-circle"),
                                                 style ="display: block; margin: 0 auto; width: 200px;color: black;"
                                    ),
                                    br()
                              ),
                             menuItem("Mean_variance relationship",
                                      br(),
                                      actionButton(inputId = "proteus_Mean_variance_Render",
                                                   label = "Render Plot",
                                                   icon = icon("play-circle"),
                                                   style ="display: block; margin: 0 auto; width: 200px;color: black;"
                                      ),
                                      br()),
                             menuItem("Protein clustering",
                                      br(),
                                      actionButton(inputId = "proteus_proteinClustering_Render",
                                                   label = "Render Plot",
                                                   icon = icon("play-circle"),
                                                   style ="display: block; margin: 0 auto; width: 200px;color: black;"
                                      ),
                                      br())
                             #menuItem("Fold_change_intensity plot",
                             #          br(),
                             #         actionButton(inputId = "proteus_Fold_change_intensity_Render",
                              #                     label = "Render Plot",
                            #                       icon = icon("play-circle"),
                            #                       style ="display: block; margin: 0 auto; width: 200px;color: black;"
                            #          ),
                            #          br()),
                             #menuItem("Volcano plot",br(),
                            #          helpText('Please wait a second until the'),
                            #          helpText('\"Options\" appear, then click'),
                            #          helpText('\"Render Plot\".'),
                            #          uiOutput('proteus_volcano_selector'),br(),
                            #          actionButton(inputId = "proteus_volcano_Render",
                            #                       label = "Render Plot",
                            #                       icon = icon("play-circle"),
                            #                       style ="display: block; margin: 0 auto; width: 200px;color: black;"
                            #          ),
                            #          br())
                             )
                         )
),
  
    
    dashboardBody(
        tabsetPanel(  # a layout
            id = 'main_tabs',
            
            # data tab
            tabPanel(title = 'Data',
                     value = 'fileinput_condition',
                     fluidPage(
                        fluidRow(
                            column(10,
                                DT::DTOutput("contents", width = '80%')
                            )
                        )
                     )
            ),

            
            # default method condition tab
            tabPanel(title = 'Default method',
                     value = 'default_method_condition',
                     
                     fluidPage(
                          fluidRow(
                              column(6,
                                     plotOutput('default_method_volcano_out')
                                     #downloadButton(outputId = "default_method_volcano_downloader", 
                                     #                label = "Download Volcano plot",
                                     #                style="color: black;")
                              ),
                              column(6,
                                     plotOutput('default_method_heat_out')
                                     #downloadButton(outputId = "default_method_heatmap_downloader", 
                                     #                label = "Download Heatmap",
                                     #                style="color: black;")
                              ),
                          ),
                          
                          br(),
                            
                          fluidRow(
                              column(9, 
                                     #align="center",   # doesn't work
                                     plotOutput('default_method_qc_out')
                                     #downloadButton(outputId = "default_method_qc_downloader", 
                                     #                label = "Download QC plot",
                                     #                style="color: black;")
                              )
                          )

                   
                     )
            ),
            
            # proteus method condition tab
            tabPanel(title = 'Proteus method',
                     value = 'proteus_condition',
                     fluidPage(
                              tabBox(# No title
                                    id = "proteus_tabbox1", selected = "proteus_tabbox_data", width = 12,
                                    tabPanel(
                                            title = "Data", value = "proteus_tabbox_data",
                                            fluidRow(
                                                    column(width = 8,
                                                           DT::DTOutput("proteus_evidence_contents")),
                                                    column(width = 4,
                                                           rHandsontableOutput("proteus_define_metadata"))
                                            )),
                                    tabPanel(
                                            title = "Plots", value = "proteus_tabbox_plots",
                                            #plotOutput('proteus_method_normalizaiton_plot_out'
                                            fluidRow(
                                                    
                                                    column(width = 5,
                                                           plotOutput('proteus_method_normalizaiton_plot_out')),
                                                    column(width = 7,
                                                           plotOutput('proteus_Mean_variance_plot_out'))),
                                            fluidRow(
                                                    column(width = 7,
                                                           plotOutput('proteus_proteinClustering_plot_out')))
                                                           #plotOutput('proteus_volcano_plot_out')))
                                    )
                                    
                              )
                         )
                     )
            )
            
        )
)



# Define server logic ----
server <- function(input, output, session) {
    options(shiny.maxRequestSize=60*1024^2)
    

    # -------------input---------------
    inputdf <- reactive({
        inFile <- input$csvFile
        if(is.null(inFile)) # the initialization should be NULL
            return(NULL)
        
        fileData <- read.csv(inFile$datapath)
    })
    
    
    output$contents <- renderDT({
        datatable(inputdf(),
                  options = list(scrollX = TRUE)
        )
    })
    
    
    # default_method volcano plot
    default_method_volcano_plot <- reactive({
        if(input$default_method_volcano_Render == 0) {
            return(NULL)
        }
        else {
            getPlot(inputdf(), flag = 'volcano', selector = input$default_method_volcano_input)
        }
    })
    
    default_method_volcano_select <- reactive({
        if(input$csvFile == 0) {
            return(NULL)
        }
        else {
            default_method_vol_selector <- getSelector(inputdf(), flag = 'volcano')
            selectInput(inputId = 'default_method_volcano_input',
                        label = 'Options',
                        choices = as.list(default_method_vol_selector)
            )
        }
    })
    
    output$default_method_volcano_selector <- renderUI({
        default_method_volcano_select()
    })
    
    output$default_method_volcano_out <- renderPlot({
        default_method_volcano_plot()
    })
    
    
    # default_method heatmap
    default_method_heatmap_plot <- reactive({
        if(input$default_method_heatmap_Render == 0) {
            return(NULL)
        }
        else {
            getPlot(inputdf(), flag = 'heat')
        }
    })
    
    output$default_method_heat_out <- renderPlot({
        default_method_heatmap_plot()
    })
    
    
    # default_method qc plot
    default_method_qc_plot <- reactive({
        if(input$default_method_qc_Render == 0) {
            return(NULL)
        }
        else {
            getPlot(inputdf(), flag = 'qc', selector = input$default_method_qc_input)
        }
    })
    
    default_method_qc_select <- reactive({
        if(input$csvFile == 0) {
            return(NULL)
        }
        else {
            default_method_qc_selector <- getSelector(inputdf(), flag = 'qc')
            selectInput(inputId = 'default_method_qc_input',
                        label = 'Options',
                        choices = as.list(default_method_qc_selector)
            )
            }
    })
    
    output$default_method_qc_selector <- renderUI({
        default_method_qc_select()
    })
    
    output$default_method_qc_out <- renderPlot({
        default_method_qc_plot()        
    })
    
    
    #### ------------Proteus-------------
    
    # control data flow
    dataControl = reactiveValues(annoStart = 0,
                                 annoSubmit = 0
    )
    
    observeEvent(input$start_anno, {
      dataControl$annoStart <-  dataControl$annoStart + 1
    })
    
    observeEvent(input$submit_anno, {
      dataControl$annoSubmit <-  dataControl$annoSubmit + 1
    })
    
    
    # Reset metadata settings
    observeEvent(input$annoReset, {
      dataControl$annoStart <- 0
      dataControl$annoSubmit <- 0
    })
    
    
    
    
    ### start_convert_to_proteus
    proteus_method_start_convert <- reactive({
      if(input$proteus_method_start_Render == 0) {
        return(NULL)
      }
      else {
        #! Note that the path also needs to be set in the python file (must be corresponding)
        py_run_file('./app/get_proteus_evidence.py')
        proteus_evidence_file <- read.csv('../data/out_proteus.csv', row.names = NULL)
        }
    })

    output$proteus_evidence_contents <- renderDT({
      datatable(proteus_method_start_convert(),
                options = list(scrollX = TRUE)
      )
    })
 
    
    ### annotate metadata for user
    categorial_anno <- reactive({
      proteus_data <- read.csv('../data/out_proteus.csv', row.names = NULL)
      proteus_experiment <- unique(proteus_data$experiment)
      proteus_intensity <- rep('Intensity', times = length(proteus_experiment))
      proteus_null <- rep('NULL', times = length(proteus_experiment))
      
      metadata <- data.frame(experiment = proteus_experiment,
                             measure = proteus_intensity,
                             sample = proteus_experiment,
                             condition = proteus_null,
                             replicate_notNecessary = proteus_null
      )
      return(metadata)
    })
    
    
    output$proteus_define_metadata <- renderRHandsontable({
      if (dataControl$annoStart > 0) {
        categorial_anno <- categorial_anno()
        categorial_anno$experiment <- as.character(categorial_anno$experiment)
        categorial_anno$measure <- as.character(categorial_anno$measure)
        categorial_anno$sample <- as.character(categorial_anno$experiment)
        categorial_anno$condition <- as.character(categorial_anno$condition)
        categorial_anno$replicate_notNecessary <- as.character(categorial_anno$replicate_notNecessary)
        tab <- rhandsontable(categorial_anno) %>%
            hot_col("experiment", readOnly = T)
        return(tab)
      } else {
        return(NULL)
      }
    })
    
    
    #get data from user
    #displays need to signal data is submitted
    proteus_metadata <- reactive({
      if (dataControl$annoSubmit > 0) {
        reps <- isolate(input$proteus_define_metadata)
        repsOut <- hot_to_r(reps)
        return(repsOut)
      } else {
        return(NULL)
      }
    })
    
    
    #This controls enabling and disabling anno button
    observe({
      if (dataControl$annoSubmit > 0) {
        sendSweetAlert(
          session = session,
          title = "Success",
          text = "Your annotation is submitted",
          type = "success", 
          closeOnClickOutside = TRUE,
          width = 400
        )
        disable("submit_anno")  # hide("proteus_define_metadata")
      } else {
        enable("submit_anno")   # show("proteus_define_metadata")
      }
    })
    
    # Proteus: create a peptide & protein dataset
    proteus_method_proteus_prodat <- reactive({
      if (dataControl$annoSubmit > 0) {
        evi <- read.csv('../data/out_proteus.csv', row.names = NULL)
        meta <- proteus_metadata()
        proteus_pepdat <- makePeptideTable(evi, meta, ncores = 1)
        proteus_prodat <- makeProteinTable(proteus_pepdat, ncores = 1)
        return(proteus_prodat)
      } else {
        return(NULL)
      }
    })
    
    
    ###   Proteus Plots
    
    # Normalizaiton
    proteus_method_normalizaiton_plot <- reactive({
      if(input$proteus_normalizaiton_Render == 0) {
        return(NULL)
      }
      else {
        proteus_prodat <- proteus_method_proteus_prodat()
        proteus_prodat.med <- normalizeData(proteus_prodat)
        proteus_prodat.quant <- normalizeData(proteus_prodat, norm.fun=limma::normalizeQuantiles)
        normalizaiton_title_name <- input$proteus_normalizaiton_select

        if(normalizaiton_title_name == "Not normalized"){
          return(
            plotSampleDistributions(proteus_prodat, title=normalizaiton_title_name, fill="condition", method="violin"))
        }
        if(normalizaiton_title_name == "Median normalization"){
          return(
            plotSampleDistributions(proteus_prodat.med, title=normalizaiton_title_name, fill="condition", method="violin"))
        }
        if(normalizaiton_title_name == "Quantile normalization"){
          return(
            plotSampleDistributions(proteus_prodat.quant, title=normalizaiton_title_name, fill="condition", method="violin"))
        }
      }
    })
    
    output$proteus_method_normalizaiton_plot_out <- renderPlot({
      proteus_method_normalizaiton_plot()
    })
    
    # Mean_variance relationship
    proteus_Mean_variance_plot <- reactive({
      if(input$proteus_Mean_variance_Render == 0) {
        return(NULL)
      }
      else {
        proteus_prodat <- proteus_method_proteus_prodat()
        proteus_prodat.med <- normalizeData(proteus_prodat)
        return(
          plotMV(proteus_prodat.med, with.loess=TRUE))
      }
    })
    
    output$proteus_Mean_variance_plot_out <- renderPlot({
      proteus_Mean_variance_plot()
    })
    
    # Protein clustering
    proteus_proteinClustering_plot <- reactive({
      if(input$proteus_proteinClustering_Render == 0) {
        return(NULL)
      }
      else {
        proteus_prodat <- proteus_method_proteus_prodat()
        proteus_prodat.med <- normalizeData(proteus_prodat)
        return(
          plotClustering(proteus_prodat.med))
      }
    })
    
    output$proteus_proteinClustering_plot_out <- renderPlot({
      proteus_proteinClustering_plot()
    })
    
    # Fold_change_intensity plot
    proteus_Fold_change_intensity_plot <- reactive({
      if(input$proteus_Fold_change_intensity_Render == 0) {
        return(NULL)
      }
      else {
        proteus_prodat <- proteus_method_proteus_prodat()
        proteus_prodat.med <- normalizeData(proteus_prodat)
        return(
          plotFID(proteus_prodat.med))
      }
    })
    
    output$proteus_Fold_change_intensity_plot_out <- renderPlot({
      proteus_Fold_change_intensity_plot()
    })
    
    ############### There are currently unsolvable bugs
    # Volcano plot
    #proteus_volcano_plot <- reactive({
    #  if(input$proteus_volcano_Render == 0) {
    #    return(NULL)
    #  }
    #  else {
    #    proteus_prodat <- proteus_method_proteus_prodat()
    #    proteus_prodat.med <- normalizeData(proteus_prodat)
    #    res <- limmaDE(proteus_prodat.med, conditions = input$proteus_volcano_conditionsInput)
    #    return(
    #      plotVolcano(res))
    #  }
    #})
    
    #proteus_volcano_select <- reactive({
    #  if(input$csvFile == 0) {
    #    return(NULL)
    #  }
    #  else {
    #    proteus_vol_selector <- getSelector(inputdf(), flag = 'proteus_volcano')
    #    selectInput(inputId = 'proteus_volcano_conditionsInput',
    #                label = 'Options',
    #                choices = as.list(proteus_vol_selector)
    #    )
    #  }
    #})
    
    #proteus_volcano_selector <- renderUI({
    #  proteus_volcano_select()
    #})
    
    #output$proteus_volcano_plot_out <- renderPlot({
    #  proteus_volcano_plot()
    #})
    
    
    
    # --------------Download---------------
    # default--------------
    # volcano

    
}

# Run the app ----
shinyApp(ui = ui, server = server)
