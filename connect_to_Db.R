##------------------------------------------------------------------------------
# Function: connect_to_Db
# Desc: sets up a database connection
# Parameters:
#   In: raw text
#   Out:
#   Returns: text without space characters
##-------------------------------------------------------------------------------

connect_to_Db <- function(){

   #connection= strsplit(decrypt_string(en_string, key = privkey, pkey = pubkey),",")

   conn <-  dbConnect(
    odbc(),
    driver = "SQL Server",
    server = "L5500-NJAB-TF13",  #connection[[1]][1],
    database =  "Test"#,  ##connection[[1]][2],
    #Uid = "GLB\njablonski", #connection[[1]][3],
    #Pwd =  "" #connection[[1]][4]
  )
  
  return(conn)
}


