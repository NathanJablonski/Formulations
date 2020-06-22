
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
  sql <- "SELECT CONCAT(Chemical_Name, ' | ', Manufacturer) as Chemical_Name FROM ChemicalInventory WHERE Active = 'Y';"
  chemical <- dbGetQuery(con, sql)
  dbDisconnect(con)

  return(chemical$Chemical_Name)
}

formSequence <- function(){
  con <- connect_to_Db()

  # Get Formulation Sequence
  sql <- "SELECT Counter FROM SeqCounter where SeqType = 'PForm';"
  seq <- dbGetQuery(con, sql)
  dbDisconnect(con)

  return(seq$Counter)
}

saveFormulation <- function(seqType, componentName, componentVendor, pctByWeight, componentType, createdBy, lastRow, formCounter, formStatus){
  con <- connect_to_Db()

  sql <- paste("EXEC CreateFormulation @seqType = N'", seqType, "',", "@componentName = N'", componentName, "',", "@componentVendor = N'", componentVendor, 
      "',", "@pctByWeight = ", pctByWeight, 
      ",", "@componentType = N'", componentType, 
      "',", "@createdBy = N'", createdBy, 
      "',", "@lastRow = N'", lastRow, 
      "',", "@formCounter = ", formCounter, 
      ",", "@formStatus = N'", formStatus, 
      "',", "@newFormID = Null", sep = "")

  cat(file=stderr(), "SQL: ", sql, "\n")

  #tryCatch({
    queryOutput <- dbGetQuery(con, sql)
    dbDisconnect(con)

    cat(file=stderr(), "Query output: ", as.character(queryOutput$newFormID), "\n")
    return(queryOutput)
  # },
  # warning = function(w) {
  #   cat(file=stderr(), "Warning: ", w, "\n")
  #   #return(data.frame(Confirmation = 'Failed to add Formulation entry'))
  #  },
  # error = function(e) {
  #   cat(file=stderr(), "Error: ", e, "\n")
  #   #return(data.frame(Confirmation = 'Failed to add Formulation entry'))
  # })
} 