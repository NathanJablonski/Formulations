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

# User interface ----
shinyUI(fluidPage(
  titlePanel("Formulation"),
  
  Form_UI('Form_UI1')
))
