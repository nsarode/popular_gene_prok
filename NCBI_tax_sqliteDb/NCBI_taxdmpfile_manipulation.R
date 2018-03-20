list.files()

## if using older nodes.dmp files (which has lesser number of columns than the new_taxdmp files)
#nodes = read.table("nodes.dmp",header=FALSE,col.names = c("tax_id","parent_tax_id","rank","embl_code","division_id","inherited_div_flag","genetic_code_id","inherited_GC_flag","mitochondrial_genetic_code_id","inherited_MGC_flag","GenBank_hidden_flag","hidden_subtree_root_flag","comments","empty"),sep = "|",stringsAsFactors = F, quote = "", check.names = F, comment.char = "")

# read the file
nodes = read.table("nodes.dmp",header=FALSE,col.names = c("tax_id","parent_tax_id","rank","embl code","division id","inherited div flag","genetic code id","inherited GC  flag","mitochondrial genetic code id","inherited MGC flag","GenBank hidden flag","hidden subtree root flag","comments","plastid genetic code id","inherited PGC flag","specified_species","hydrogenosome genetic code id","inherited HGC flag","empty"),sep = "|",stringsAsFactors = F, quote = "", check.names = F, comment.char = "")

# subset relevant columns
node = subset(nodes,select = c("tax_id","parent_tax_id","rank"))

# take care of rampant additional tabs in the file
node = as.data.frame(apply(node,2, function(x) gsub("\t","",x)))
unique(node$rank) # double check that the rank levels make sense

# write the table
write.table(node, "selected_node_Mar18.dmp", sep="\t", quote=F, col.names=TRUE, row.names=FALSE, na="EMPTY")

# do the same for names.dmp file
names = read.table("names.dmp", header=FALSE, col.names = c("tax_id","name_txt","unique_name","name_class","empty"),sep = "|",stringsAsFactors = F, quote = "", check.names = F, comment.char = "")
name = as.data.frame(apply(names,2, function(x) gsub("\t","",x)))
name_class = unique(name$name_class)
write.table(name, "selected_name_Mar18.dmp", sep="\t", quote=F, col.names=TRUE, row.names=FALSE, na="EMPTY")
