

# User interface ---- 

Form_UI <- function(id){
  source("loadData.R", local = TRUE)
  source("connect_to_Db.R", local =TRUE)
  ns <- NS(id)

#shinyUI(fluidPage(
  #tabsetPanel(
  
  	tabPanel("Create Formulation",
  		fluidPage(titlePanel("Formulations"),
  		  sidebarLayout(
  		    sidebarPanel(width = 5,
      			fluidRow(
      				column(5, selectInput(ns("componentsForm"), label = "Components:", width = '600px', list("Select one" = c("Select one"), "Components" = c('Sequence','Recipe', chemicals())))),
					bsTooltip(ns("componentsForm"), "Select a Component. Sequence or Recipe selections open new drop-down menu.", placement = "top", trigger = "hover",  options = NULL),                                     
				 	column(2, numericInput(ns("componentWtForm"), label = "% By Weight:", 0, min = 0.01, max = 100)),
					bsTooltip(ns("componentWtForm"), "Enter a % By Weight", placement = "right", trigger = "hover",  options = NULL),  
      			),
      					
      			fluidRow(
      				column(3,uiOutput(ns("Seq_or_recipe_display"))),
      			),
      
      			br(),
      			fluidRow(
      				actionButton(ns("AddComponentForm"), "Add Component", icon("plus-circle")),
					bsTooltip(ns("AddComponentForm"), "Click to add Component and % By Weight to grid", placement = "top", trigger = "hover",  options = NULL),
					actionButton(ns("RemoveComponentForm"), "Remove Component", icon("minus-circle")),
					bsTooltip(ns("RemoveComponentForm"), "Highlight row in grid below and click to remove", placement = "top", trigger = "hover",  options = NULL),
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
					bsTooltip(ns("SubmitForm"), "Click to create Formulation", placement = "top", trigger = "hover",  options = NULL),
      			),
      			br(),
      			
      			fluidRow(
      				h4(htmlOutput(ns('formSubmitText')))
      			),
  		    ),
  		    mainPanel( width = 5,
             fluidRow(
               h3("Saved Formulations")                	
             ),
             DT::dataTableOutput(ns("SavedFormsTable")),
  		) 
  	  )			
	 )
    )#,

# 	tabPanel("Notes",
		
# 	)
	
#    )
#   )
#  )
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
	  
	  output$SavedFormsTable <- DT::renderDataTable(DT::datatable({
		
	  savedFormulations()[, c("Formulation_ID",'Component','Manufacturer', 'Pct_By_Weight',"Component_Type")]
		
    }))
	
	savedFormulations <- reactive({
		input$SubmitForm
		query = paste0("select f.Formulation_ID as Formulation_ID, ISNULL(c.Chemical_Name, f.Universal_ID) as Component, c.Manufacturer as Manufacturer, f.Pct_By_Weight as Pct_By_Weight, ISNULL(c.Chemical_Type, 'Sequence') as Component_Type from FormulationComponents2 f left join ChemicalInventory c on f.Chemical_ID = c.Chemical_ID order by createdt;")
		getTableData(query)
   })
	
	  
	#############################################
	observeEvent(input$AddComponentForm, {

	   output$formErrorText <- renderUI({span("")})

	  if(input$componentWtForm <= 0){
		output$formErrorText <- renderUI({
			span("Error - % By Weight Must Be > 0", style = "color:orange")})
	  }
	  else if(input$componentWtForm > 100){
		output$formErrorText <- renderUI({
			span("Error - % By Weight Must Be < 100", style = "color:orange")})
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
		print(paste("Sequence #: ",seqVal))
		formCreation = ""
		#formDF <- data.frame(Component = character(), Percent_By_Wt = character(), Component_Type = character(), Manufacturer = character())		

		for(i in 1:nrow(formTableData())){
			componentName <- ""
			componentVendor <- ""
			universalID <- ""
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
			
			if(componentType == 'Sequence'){
				universalID <- componentName
				componentName <- ""
				componentVendor <- ""
			}

			print(componentName)
			print(componentVendor)

			if(i == nrow(formTableData())){
				lastRow <- 'TRUE'
			}

			#t = rbind(data.frame(Component = componentName,
			#		             Percent_By_Wt = newPctWt,
			#		             Component_Type = componentType,
			#     				 Manufacturer = componentVendor), formDF())	

			#formDF(t)		

			#formCreation = saveFormulation('PFORM', componentName, componentVendor, newPctWt, componentType, 'Nathan Jablonski', lastRow, seqVal, 'New')
			#formCreation = saveFormulation('PFORM', componentName, componentVendor, universalID, newPctWt, 'PFORM', userID, lastRow, seqVal, 'New')
			formCreation = saveFormulation('PFORM', componentName, componentVendor, universalID, newPctWt, 'PFORM', 'njablonski', lastRow, seqVal, 'New')
		}
		#formCreation = saveFormulation(formDF(), seqVal, 'PFORM', 'Nathan Jablonski', 'New')

		output$formSubmitText <- renderUI({
			HTML(paste("Formulation Created: ", "<b>", as.character(formCreation$newFormID),"</b>"))   
		})
	})
	################################################# 
}