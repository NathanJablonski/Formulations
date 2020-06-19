

# User interface ---- 

Form_UI <- function(id){
  source("loadData.R", local = TRUE)
  source("connect_to_Db.R", local =TRUE)
  ns <- NS(id)

shinyUI(fluidPage(
  titlePanel("Formulation"),
  
  
	tabPanel("Formulations", (
		fluidPage(
			
			fluidRow(
				column(3, selectInput(ns("componentsForm"), label = "Components:", width = '500px', list("Select one" = c("Select one"), "Components" = c('Sequence','Recipe', components())))),                  
				column(2, textInput(ns("componentWtForm"), label = "% By Weight:")),
			),
					
			fluidRow(
				column(3,uiOutput(ns("Seq_or_recipe_display"))),
			),

			br(),
			fluidRow(
				actionButton(ns("AddComponentForm"), "Add Component", icon("plus-circle")),
				actionButton(ns("EditComponentForm"), "Edit", width = '140px', icon("edit")),
				actionButton(ns("RemoveComponentForm"), "Remove Component", icon("minus-circle")),
			),
			fluidRow(
				uiOutput(ns('formErrorText'))
			),
			br(),	

			fluidRow(
			column(6,
				DT::dataTableOutput(ns("FormulationDT")), 
			),
			),
			br(),

			fluidRow(
				column(3, h4(htmlOutput(ns("PctFilledForm")))),
				column(2, actionButton(ns("SubmitForm"), "Submit", width = '140px', icon("arrow-alt-circle-right"))),
			),		
			
		)
	)))
  ) 
  
  }
  

Form <- function(input, output, session) {
	source("loadData.R", local = TRUE)
    source("connect_to_Db.R", local =TRUE)
	
	formTableData <- data.frame(Component = character(), Percent_By_Wt = character())      
    formTableData <- reactiveVal(formTableData)	
	
	output$FormulationDT <-
	  DT::renderDataTable(DT::datatable(
		options = list(
		  pageLength = 10 ,
		  paging = FALSE,
		  searching = FALSE      
		),
		{
		  formTableData()
		},
		selection = "single", editable = list(target = "row", disable = list(columns = c(0,1)))
	  ))
	  
	#############################################
	observeEvent(input$AddComponentForm, {

	  if(nchar(input$componentWtForm) == 0){
		output$formErrorText <- renderUI({
			span("Error - Need to Enter % By Weight", style = "color:orange")})
	  }	  
	  else{
		 if(input$componentsForm =='Sequence'){
			t = rbind(data.frame(Component = input$sequenceForm, 
  							     Percent_By_Wt = input$componentWtForm), formTableData())
  
  			formTableData(t)
		}
		else if(input$componentsForm == 'Recipe'){
			t = rbind(data.frame(Component = input$recipeForm, 
  							     Percent_By_Wt = input$componentWtForm), formTableData())
  
  			formTableData(t)
		}
		else{
			t = rbind(data.frame(Component = input$componentsForm,
  							     Percent_By_Wt = input$componentWtForm), formTableData())
  
  			formTableData(t)
		}  
  
  		output$formErrorText <- renderUI({
  			  span("")})
  
  		output$PctFilledForm <- 
  		  renderUI({
  			HTML(paste("<b>","% Filled: ","</b>", sum(as.numeric(as.character(formTableData()$Percent_By_Wt)))))       
		  })
	  }
	})	
	
	observeEvent(input$RemoveComponentForm, {
	  t = formTableData()

	  if(!is.null(input$FormulationDT_rows_selected)) {
		  t <- t[-as.numeric(input$FormulationDT_rows_selected),]
	  }
	  formTableData(t)

	  output$PctFilledForm <- 
		renderUI({
		  HTML(paste("<b>","% Filled: ","</b>", sum(as.numeric(as.character(formTableData()$Percent_By_Wt)))))       
		})
	})

	output$Seq_or_recipe_display <- renderUI ({
	
		req(input$componentsForm)
		
		if(input$componentsForm =='Sequence'){		
			selectInput(session$ns("sequenceForm"), label = "Universal ID:", width = '500px', list("Select one" = c("Select one"), "Values" = c("GS1", "GS2", "GS3")))
		}
		else if (input$componentsForm =='Recipe') {
			selectInput(session$ns("recipeForm"), label = "Recipe:", width = '500px', list("Select one" = c("Select one"), "Values" = c("Recipe 1", "Recipe 2", "Recipe 3")))
		}			
		else {}
	
	})

	observeEvent(input$SubmitForm, {
		cat(file=stderr(), "Num rows: ", nrow(formTableData()), "\n")
		cat(file=stderr(), "Component 1: ", formTableData()$Component[2], "\n")

		saveFormulation()
	})
	################################################# 
}