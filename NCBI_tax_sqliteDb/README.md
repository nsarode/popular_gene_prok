# Building an `sqlite` database from NCBI's `names.dmp` and `nodes.dmp` files

### Purpose

### To efficiently retrieve taxonomy information, be it scientific name or entire lineage, based on using NCBI `taxid` or name

#### Steps:

1. Download `new_taxdump.tar.gz` from `ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/`

On linux machine

`wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz*`

On mac

`curl -o ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz*`

This will download two files:
  - `new_taxdump.tar.gz`
  -  `new_taxdump.tar.gz.md5`

Since this is a big file, we wanna utilize the `md5` value to confirm we downloaded the complete file without any issues. Most efficient way to do this:

```
md5 -c new_taxdump.tar.gz.md5
```
which should (ideally) generate the following stdout

```
new_taxdump.tar.gz: OK
```
If everything is OK, uncompress the file

```
tar -zxvf new_taxdump.tar.gz
```

2. Now we use script [NCBI_sqliteDb_creation.R](NCBI_sqliteDb_creation.R) to

  - first create two files : `selected_names_Mar18.dmp` & `selected_nodes_Mar18.dmp` 
  - create a sqlite database `NameNode.sqlite`
