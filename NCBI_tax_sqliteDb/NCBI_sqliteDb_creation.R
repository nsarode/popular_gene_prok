## if using older nodes.dmp files (which has lesser number of columns than the new_taxdmp files)
#nodes = read.table("nodes.dmp",header=FALSE,col.names = c("tax_id","parent_tax_id","rank","embl_code","division_id","inherited_div_flag","genetic_code_id","inherited_GC_flag","mitochondrial_genetic_code_id","inherited_MGC_flag","GenBank_hidden_flag","hidden_subtree_root_flag","comments","empty"),sep = "|",stringsAsFactors = F, quote = "", check.names = F, comment.char = "")

# if using new_taxdmp files 
#read the file
nodes = read.table("nodes.dmp",header=FALSE,col.names = c("tax_id","parent_tax_id","rank","embl code","division id","inherited div flag","genetic code id","inherited GC  flag","mitochondrial genetic code id","inherited MGC flag","GenBank hidden flag","hidden subtree root flag","comments","plastid genetic code id","inherited PGC flag","specified_species","hydrogenosome genetic code id","inherited HGC flag","empty"),sep = "|",stringsAsFactors = F, quote = "", check.names = F, comment.char = "")

# subset relevant columns
selected_node = subset(nodes,select = c("tax_id","parent_tax_id","rank"))

# take care of rampant additional tabs in the file
selected_node = as.data.frame(apply(selected_node,2, function(x) gsub("\t","",x)))
unique(selected_node$rank) # double check that the rank levels make sense

# write the table
write.table(selected_node, "selected_node_Mar18.dmp", sep="\t", quote=F, col.names=TRUE, row.names=FALSE, na="EMPTY")

# do the same for names.dmp file
names = read.table("names.dmp", header=FALSE, col.names = c("tax_id","name_txt","unique_name","name_class","empty"),sep = "|",stringsAsFactors = F, quote = "", check.names = F, comment.char = "")
selected_name = subset(names,select = c("tax_id","name_txt","unique_name","name_class"))
selected_name = as.data.frame(apply(selected_name,2, function(x) gsub("\t","",x)))
write.table(selected_name, "selected_name_Mar18.dmp", sep="\t", quote=F, col.names=TRUE, row.names=FALSE, na="EMPTY")

##################################################################################
#create the database
# if starting from already generated 'selected_name/node_Mar18.dmp' files, read them using code below
selected_name = read.table("selected_name_Mar18.dmp", header = T, sep = "\t", comment.char = "", fill = T, quote = "") # quote = "" to take care of 'EOF within quote string' warning; fill = T to take care of uneven number of columns
selected_node = read.table("selected_node_Mar18.dmp", header = T, sep = "\t", comment.char = "", fill = T, quote = "") 
NameNode = merge.data.frame(selected_name,selected_node, by = "tax_id")

sapply(NameNode, class) # check class of each column
NameNode[,c(2:4,6)] = sapply(NameNode[,c(2:4,6)], as.character)
sapply(NameNode, class) # check


library(RSQLite)
con <- dbConnect(SQLite(), "NameNode.sqlite") # open connection
dbWriteTable(con, name="NcbiNameNode", value=NameNode, row.names=FALSE, append=TRUE) # write the db for future access
dbDisconnect(con)
#################################################################################
 con <- dbConnect(SQLite(), "NameNode.sqlite") # open connection

# sanity check
dbListTables(con)                   # The tables in the database
dbListFields(con,"NcbiNameNode")    # The columns in a table
results <- dbGetQuery(con, "SELECT tax_id, name_txt FROM NcbiNameNode WHERE tax_id == 1716141 AND name_class = 'scientific name'") ;
results <- dbGetQuery(con, "SELECT tax_id, name_txt, rank FROM NcbiNameNode WHERE tax_id == 9 AND name_class = 'scientific name'") ;
dbDisconnect(con) # close connection after use

#########################################################################################
