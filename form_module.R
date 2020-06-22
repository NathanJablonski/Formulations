

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
				column(5, selectInput(ns("componentsForm"), label = "Components:", width = '600px', list("Select one" = c("Select one"), "Components" = c('Sequence','Recipe', components())))),                  
				column(2, textInput(ns("componentWtForm"), label = "% By Weight:")),
			),
					
			fluidRow(
				column(3,uiOutput(ns("Seq_or_recipe_display"))),
			),

			br(),
			fluidRow(
				actionButton(ns("AddComponentForm"), "Add Component", icon("plus-circle")),
				#actionButton(ns("EditComponentForm"), "Edit", width = '140px', icon("edit")),
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
			br(),
			
			fluidRow(
				h4(htmlOutput(ns('formSubmitText')))
			),		
			
		)
	)))
  ) 
  
  }
  

Form <- function(input, output, session) {
	source("loadData.R", local = TRUE)
    source("connect_to_Db.R", local =TRUE)
	
	formTableData <- data.frame(Component = character(), Percent_By_Wt = character(), Component_Type = character())      
    formTableData <- reactiveVal(formTableData)	
	
	output$FormulationDT <-
	  DT::renderDataTable(DT::datatable(
		options = list(
		  pageLength = 10 ,
		  paging = FALSE,
		  searching = FALSE,
		  autoWidth = TRUE,
		  columnDefs = list(list(width = '200px', targets = c(1)))      
		),
		{
		  formTableData()
		},
		selection = "single"  #, editable = list(target = "row", disable = list(columns = c(0,1)))
	  ))
	  
	#############################################
	observeEvent(input$AddComponentForm, {

	  if(nchar(input$componentWtForm) == 0){
		output$formErrorText <- renderUI({
			span("Error - Need to Enter % By Weight", style = "color:orange")})
	  }
	  else if(input$componentsForm == 'Select one'){
		  output$formErrorText <- renderUI({
			span("Error - Please Select a Component", style = "color:orange")})
	  }	
	  else if(input$componentsForm == 'Sequence' && input$sequenceForm == 'Select one'){
		  output$formErrorText <- renderUI({
			span("Error - Please Select a Sequence", style = "color:orange")})
	  }
	  else if(input$componentsForm == 'Recipe' && input$recipeForm == 'Select one'){
		  output$formErrorText <- renderUI({
			span("Error - Please Select a Recipe", style = "color:orange")})
	  }	   	    
	  else{
		 if(input$componentsForm =='Sequence'){
			t = rbind(data.frame(Component = input$sequenceForm, 
  							     Percent_By_Wt = input$componentWtForm,
								 Component_Type = 'Sequence'), formTableData())
  
  			formTableData(t)
		}
		else if(input$componentsForm == 'Recipe'){
			t = rbind(data.frame(Component = input$recipeForm, 
  							     Percent_By_Wt = input$componentWtForm,
								 Component_Type = 'Recipe'), formTableData())
  
  			formTableData(t)
		}
		else{
			t = rbind(data.frame(Component = input$componentsForm,
  							     Percent_By_Wt = input$componentWtForm,
								 Component_Type = 'Chemical'), formTableData())
  
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

		output$formSubmitText <- renderUI({span("Creating Formulation", style = "color:black")})

		lastRow <- 'FALSE'
		seqVal <- formSequence()
		formCreation = ""		

		for(i in 1:nrow(formTableData())){
			componentName <- ""
			componentVendor <- ""
			newComponent = formTableData()$Component[i]
			newPctWt = trimws(formTableData()$Percent_By_Wt[i])
			componentType = formTableData()$Component_Type[i]
			splitComponent1 = as.character(newComponent)
			splitComponent = strsplit(splitComponent1," | ", fixed = TRUE)

			if(grepl(" | ", splitComponent) == TRUE){
				componentName = sapply(strsplit(splitComponent1," | ", fixed = TRUE), getElement, 1)
				if(length(splitComponent[[1]]) > 1){
					componentVendor = sapply(strsplit(splitComponent1," | ", fixed = TRUE), getElement, 2)
				}					
			}
			else{
				componentName = newComponent
			}

			print(componentName)
			print(componentVendor)

			if(i == nrow(formTableData())){
				lastRow <- 'TRUE'
			}			

			formCreation = saveFormulation('PFORM', componentName, componentVendor, newPctWt, componentType, 'Nathan Jablonski', lastRow, seqVal, 'New')
		}

		output$formSubmitText <- renderUI({
			HTML(paste("Formulation Created: ", "<b>", as.character(formCreation$newFormID),"</b>"))   
		})
	})
	################################################# 
}