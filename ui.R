library(shiny)
library(odbc)
library(shinythemes)
library(shinybusy)
library(rclipboard)
library(shinyBS)
library(DT)
library(stringr)

#source("loadData.R", local = TRUE)
#source("connect_to_Db.R", local =TRUE)
source("NotesModule.R", local = TRUE)

# User interface ----
shinyUI(fluidPage(
  titlePanel("Formulations"),
  
  tabsetPanel(
    Form_UI('Form_UI1'),
    NotesModule_UI('Form_NotesUI')
  )
  
))
