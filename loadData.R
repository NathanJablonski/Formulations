
#source("connect_to_Db.R", local =TRUE)

components <- function(){
	con <- connect_to_Db()
  # con <- dbConnect(
  #   odbc(),
  #   driver = "SQL Server",
  #   server = "L5500-NJAB-TF13",  
  #   database =  "Test"
  # )
	
	# Get all components
  sql <- "SELECT distinct Chemical_Name FROM ChemicalInventory;"
  chemical <- dbGetQuery(con, sql)
  dbDisconnect(con)
  return(chemical$Chemical_Name)
}

saveFormulation <- function(){
  con <- connect_to_Db()

  sql <- "INSERT INTO FormulationComponents (Formulation_ID, Component, Manufacturer,Pct_By_Weight, Type, Created_By)
          VALUES('PF2', 'Glycol', 'Sigma', 25, 'PForm', 'Nathan')"

  form <- dbGetQuery(con, sql)
  dbDisconnect(con)
  #return(form)
} 