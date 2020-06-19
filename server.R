
library(shiny)

source("form_module.R", local =TRUE)
#source("loadData.R", local = TRUE)
#source("connect_to_Db.R", local =TRUE)

# Server logic ----
function(input, output, session) {
	callModule(Form, "Form_UI1")
}

