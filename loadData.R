
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
  sql <- "SELECT CONCAT(Chemical_Name, ' | ', Manufacturer) as Chemical_Name FROM ChemicalInventory WHERE Active = 'Y' ORDER BY Chemical_Name;"
  chemical <- dbGetQuery(con, sql)
  dbDisconnect(con)

  return(chemical$Chemical_Name)
}

formSequence <- function(){
  con <- connect_to_Db()

  # Get Formulation Sequence
  sql <- "SELECT FORMAT(Counter, '00000') as Counter FROM SeqCounter where SeqType = 'PForm';"
  seq <- dbGetQuery(con, sql)
  dbDisconnect(con)

  return(seq$Counter)
}

chemicals <- function(){
  con <- connect_to_Db()

  # Get all chemicals
  sql <- "SELECT CONCAT(Chemical_Name, ' | ', Manufacturer) as Chemical_Name FROM ChemicalInventory WHERE Active = 'Y' AND Chemical_Type = 'Chemical' ORDER BY Chemical_Name;"
  chemical <- dbGetQuery(con, sql)
  dbDisconnect(con)
  return(chemical$Chemical_Name)
}

#savedFormulations <- function(){
#  con <- connect_to_Db()

  # Get saved Formulations
#  sql <- "select f.Formulation_ID as Formulation_ID, ISNULL(c.Chemical_Name, f.Universal_ID) as Component, c.Manufacturer as Manufacturer, f.Pct_By_Weight as Pct_By_Weight, ISNULL(c.Chemical_Type, 'Sequence') as Component_Type from FormulationComponents2 f left join ChemicalInventory c on f.Chemical_ID = c.Chemical_ID order by createdt;"
#  results <- dbGetQuery(con, sql)
#  dbDisconnect(con)

#  return(results)
#}

getTableData <-  function(query){

  con2 <- connect_to_Db()

  dataout <-  dbGetQuery(con2, query) 
  dbDisconnect(con2)

  dataout
}

getNoteSeq <- function(){
  con <- connect_to_Db()

  # Get Notes sequence
  sql <- "select MAX(Row_ID) + 1 as NoteSeq from FormulationNotes;"
  seq <- dbGetQuery(con, sql)
  dbDisconnect(con)
  return(seq$NoteSeq)
}

#saveFormulation <- function(seqType, componentName, componentVendor, pctByWeight, componentType, createdBy, lastRow, formCounter, formStatus){
saveFormulation <- function(seqType, componentName, componentVendor, universalID, pctByWeight, formType, createdBy, lastRow, formCounter, formStatus){
  con <- connect_to_Db()

  # sql <- paste("EXEC CreateFormulation @seqType = N'", seqType, "',", "@componentName = N'", componentName, "',", "@componentVendor = N'", componentVendor, 
  #     "',", "@pctByWeight = ", pctByWeight, 
  #     ",", "@componentType = N'", componentType, 
  #     "',", "@createdBy = N'", createdBy, 
  #     "',", "@lastRow = N'", lastRow, 
  #     "',", "@formCounter = ", formCounter, 
  #     ",", "@formStatus = N'", formStatus, 
  #     "',", "@newFormID = Null", sep = "")
  
  sql <- paste("EXEC CreateFormulation @seqType = N'", seqType, "',", "@componentName = N'", componentName, "',", "@componentVendor = N'", componentVendor, 
      "',", "@universalID = N'", universalID,
      "',", "@pctByWeight = ", pctByWeight, 
      ",", "@formType = N'", formType, 
      "',", "@createdBy = N'", createdBy, 
      "',", "@lastRow = N'", lastRow, 
      "',", "@formCounter = ", formCounter, 
      ",", "@formStatus = N'", formStatus, 
      "',", "@newFormID = Null", sep = "")

  #sql <- paste("EXEC CreateFormulation_Test @formTable = '", dfData,
  #    "',", "@formCounter = ", formCounter, 
  #    "',", "@seqType = N'", seqType, 
  #    "',", "@createdBy = N'", createdBy,  
  #    ",", "@formStatus = N'", formStatus, sep = "")

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