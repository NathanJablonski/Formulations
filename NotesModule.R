##------------------------------------------------------------------------------
# File: NotesModule.R
# Name: Nathan Jablonski
# Date: 7/10/2020
# Desc: Code for loading adding notes to Formulations
# Usage:
#
##-------------------------------------------------------------------------------

NotesModule_UI <- function(id){
  ns <- NS(id)

  tabPanel("Notes",
    fluidPage(
      titlePanel("Add/Review Notes"),

      selectizeInput(ns('formSelect'), label = "Select Formulation:", list("Select one" = c("Select one"), "Values" = c("PF00027", "PF00028"))),
      br(),
     
      h4(htmlOutput(ns('componentText'))),
      DT::dataTableOutput(ns("formComponentDT"), width = "600px"),
      br(),

      textAreaInput(ns("formNotesInput"), label = "Enter a Note:", placeholder = "Enter a new note here...", width = "300px", rows = 2),

      actionButton(ns("SubmitNotes"), "Submit", width = '140px', icon("arrow-alt-circle-right")),
      br(),

      fluidRow(
					h4(htmlOutput(ns('noteSubmitText')))
			),
      tags$br(),
      tags$hr(),

      h4(htmlOutput(ns('notesText'))),
      DT::dataTableOutput(ns("formNotesDT"), width = "600px"),	
    )
  )

}

NotesModule <- function(input, output, session) {
  source("loadData.R", local = TRUE)
  source("connect_to_Db.R", local =TRUE)

  output$formComponentDT <- DT::renderDataTable(DT::datatable(
  {      
    output$componentText <- renderUI({
        HTML("Formulation Components")
    })

    retrieveFormulation()[, c("Formulation_ID",'Component','Manufacturer', 'Pct_By_Weight',"Component_Type")]      
  }))

  retrieveFormulation <- reactive({
    query = paste("select f.Formulation_ID as Formulation_ID, ISNULL(c.Chemical_Name, f.Universal_ID) as Component, c.Manufacturer as Manufacturer, f.Pct_By_Weight as Pct_By_Weight, ISNULL(c.Chemical_Type, 'Sequence') as Component_Type from FormulationComponents2 f left join ChemicalInventory c on f.Chemical_ID = c.Chemical_ID where f.Formulation_ID = '", input$formSelect, "' order by createdt;", sep = "")
    getTableData(query)
  })

  output$formNotesDT <- DT::renderDataTable(DT::datatable(
  {      
    output$notesText <- renderUI({
        HTML("Formulation Notes")
    })
    
    retrieveNotes()[, c("Formulation_ID",'Note_Content','Created_Datetime', 'Created_By')]      
  }))

  retrieveNotes <- reactive({
    input$SubmitNotes
    query = paste("select Formulation_ID, Note_Content, createdt as Created_Datetime, createby as Created_By from FormulationNotes where Formulation_ID = '", input$formSelect, "' order by createdt;", sep = "")
    getTableData(query)
  })

  observeEvent(input$SubmitNotes, {
    noteSeq = getNoteSeq()
    print(paste("Notes Seq: ", noteSeq))
    sql = paste("INSERT INTO FormulationNotes (Row_ID, Formulation_ID, createby, createdt, Note_Content) Values(", noteSeq, ",'", input$formSelect, "','njablonski', SYSDATETIME(),'", input$formNotesInput,"')", sep = "")
    print(sql)
    queryOutput <- getTableData(sql)

    print(paste("Update output: ", queryOutput))

    if(length(queryOutput) == 0){
      output$noteSubmitText <- renderUI({
        HTML("Note Saved")
      })
    }    
  })
}