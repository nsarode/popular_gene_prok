# popular_gene
Trying to recreate article The most popular genes in the human genome (https://www.nature.com/articles/d41586-017-07291-9) for prokaryotes (bacteria)

**Why ?**
I am a python newbie, but not new to programming _per se_. I am good with R, Perl and have an undiagnosed OCD of trying to write efficient shell one-liners ;-)

R was a self-taught effort and I came to realize pretty early on that when it comes to programming, 
  > reading basics only takes you so far ... pick up a project and learn along the way !

### Step1 - Fork it !

#### Make sure that the forked repo can be synced with the original repo

### Step2 - Creating a safe environment for play aka Conda !

### Now follow the instructions

#### Get list of citations by date

`python scripts/pmids_by_date.py --startdate 1990/01/01 --enddate 2017/11/05`

:interrobang: Hiccup 1 :interrobang:
 
`FileNotFoundError: [Errno 2] No such file or directory: './data/pmid_by_date/1990_01_02.ssv'`

##### Troubleshooting 101 - Look at the damned code 

At first glance, one obvious mistake appeared to be that I was not specifying the `--output-dir` parameter for the script. However that didn't solve the issue. The error just changed to now include the outdir path I provided . So the issue was not that I didn't give that option (since from the code it is obvious that it should default to `./data/pmid_by_date`). 

:zap: Turns out that python can't just create paths willy nilly unless you specifically ask it to do so ! Simple Googling and ol faithful [Stackoverflow](https://stackoverflow.com/questions/12517451/automatically-creating-directories-with-file-output) helped solve the issue.

Code edits (changed commited and pushed on github), 
```python
import os
os.makedirs(os.path.dirname(filename), exist_ok=True)
```

Lets try again

`python gene-citation-counts/scripts/pmids_by_date.py --startdate 1990/01/01 --enddate 2017/11/05`

:tada: **it worked !!**

##### What does that pmids_by_date.py do ?

The script takes range of dates as input (defaults to 2014/01/01 if none provided), and then uses NCBI's [eutils](https://www.ncbi.nlm.nih.gov/books/NBK179288/) to download a list of PubmedID's for those dates (max records downloaded 100000). It will create a `ssv` format file (with date as filename) that contains date and Pubmed article ID separated by space.

:question: A quick advanced pubmed search (webpage) revealed that the number of publications on it for the given date range is 18851774. Can we check if we got all records ? 

:bookmark: Add help menu to the script !

**Consolidate the publications from each day into one complete list**

Editing the provided command to fit my needs

```
mkdir -p /data/consolidated
for FILE in $(find data/pmid_by_date -name "*.ssv"); do cat $FILE | awk '{split($1,a,"-"); print a[1], $2}' >> data/consolidated/recent_pmid_year.ssv; done;
```
The above command will generate a consolidated file that contains the Year of publication and the PubmedID

#### Get NCBI's genes to publications table

```
mkdir -p ./data/genbank-data
wget -N -P ./data/genbank-data/ ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2pubmed.gz
gunzip ./data/genbank-data/gene2pubmed.gz

```
The file `gene2pubmed` contains 3 columns
  1. tax_id
  2. Gene_ID
  3. Pubmed_ID

This is an interesting file to explore. Lets see some quick facts about it !
There are total 10695821 lines in this file (not counting the column header). But does this means that there are 10695821 publications ? A quick `head` or `tail` of the file will let you know thats not the case. A single publication worked on multiple genes from each species, the same species (and/or genes) were studies by multiple publications... so on and so forth.

How many unique species are listed in this document ?

`awk '{print $1}' gene2pubmed| sort | uniq | wc -l` 13951

Doing the same for genes and pubmedID (only changing the column in `awk`) we also see that there are `6002840` unique genes and `1124098` pubmed articles in total.



What
`awk '{print $1}' gene2pubmed | sort -nr | uniq -c | sort -nr |head`

According to the original instructions, all genes that are assigned to Human (tax_id 9606) were selected for further analysis. This is where my protocol will __branch out__ from the original one. I am not really that interested in Human genes. Its the bacteria that fascinate me ! Now here is the rub, Bacteria is a superkingdom (tax_id 2); what this list contains is tax_id species. So now how do we deal with this ?
