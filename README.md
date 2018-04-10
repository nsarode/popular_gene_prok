# Popular genes in prokaryotes

This repo contains my scripts to:

- replicate the analysis in the article [The most popular genes in the human genome](https://www.nature.com/articles/d41586-017-07291-9)

- repeat the analysis for prokaryotes (focussing on bacteria for starters) and see what I get. 

**Why ?**

I am a python newbie, but not new to programming _per se_. I am good with R, Perl and have an undiagnosed OCD of trying to write efficient shell one-liners ;-)

R was a self-taught effort and I came to realize pretty early on that when it comes to programming, 
  > reading basics only takes you so far ... pick up a project and learn along the way !

And prokaryotes because, lets face it ... its a microbial world ! 

## Prep

### Step1 - Fork it !

Fork the [original repo](https://github.com/pkerpedjiev/gene-citation-counts.git) for scripts and instructions

### Step2 - Creating a safe environment for play aka Conda !

Checkout my [gist](https://gist.github.com/nsarode/e37f3284c11d69192b905fe998553b2a) for Conda installation instructions and commands

## Now follow the instructions

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

Most (if not all) FTP sites will have a README file explaining the directory/file structure and content. The [gene2pubmed readme](gene2pubmed_README.md) tell me that it is updated daily and it contains 3 tab separated columns

  1. tax_id
  2. Gene_ID
  3. Pubmed_ID

This is an interesting file to explore. Lets see some quick facts about it !

There are total 10695821 lines in this file (not counting the column header). But does this means that there are 10695821 publications ? A quick `head` or `tail` of the file will let you know thats not the case. A single publication worked on multiple genes from each species, the same species (and/or genes) were studies by multiple publications... so on and so forth.

How many unique species are listed in this document ?

`awk '{print $1}' gene2pubmed| sort | uniq | wc -l` 13951 (subtract 1 for column header)

Doing the same for genes and pubmedID (only changing the column in `awk`) we also see that there are `6002839` unique genes and `1124097` pubmed articles in total.

Questions that come to mind:
- What the the genes that were most studied ? i.e. most publications associated with it. We know from the original publication that `TP53` is the most studied gene. But what about in bacteria ? Similarly ...
- Most studied species ? Can we narrow this down to different taxa levels ? 
- If we move to the consolidated file (by year), do the results above hold true between the years we restricted to ? Any trend associated with year?
- On the flip side what is the least studied species? Can we get proof of concept using NCBI's taxidToGeneNames.pl script ?
- Within species, what genes are most studied per taxa ?
- Is there a correlation between the most studied gene and the most studied taxa ?

I guess the questions will never end. Lets begin ...

## Bacteria is a superkingdom :smile:

According to the original instructions, all genes that are assigned to Human (tax_id 9606) were selected for further analysis. This is where my protocol will __branch out__ from the original one. I am not really that interested in Human genes. Its the bacteria that fascinate me ! 
However, Bacteria is a superkingdom (tax_id 2); what this list contains is tax_id species. So now how do we deal with this ?

NCBI has the following taxids for the 5 different superkingdoms.

| Tax_id | Parent tax_id | Name |
| ---- | ---- | ---- |
| 2 |	131567	| Bacteria |
| 2157	| 131567	| Archaea |
| 2759	| 131567	| Eukaryote |
| 10239	| 1	| Viruses |
| 12884	| 1	| Viriods |

We need to determine the superkindgdom (and classification) of individual taxid's in the gene2pubmed file to identify and separate bacteria (possibly move on to other prokaryotes later). [NCBI taxonomy](https://www.ncbi.nlm.nih.gov/taxonomy) is a fine resource when you have few taxa to search for. But for our purposes, this is not feasible !

### Sqlite to the rescue !

I had faced this issue before and had created a handy R script to create a database using NCBI's taxonomy files ! I could try to re-write the script in python, but chose not to waste time on it <sup>**</sup>. The scripts and relevant instructions to create the database are [here](NCBI_tax_sqliteDb/)

<sup>**</sup> There are multiple perfectly good modules/packages that can give you NCBI taxonomy information from taxid (for e.g. [ETE toolkit](http://etetoolkit.org/) is an excellent package). But I wrote the script to create the database at a time when (a) there were not many packages available; (b) I was learning R and thought learning both R and sqlite won't be a bad practice.

### Take-off to Jupyter :rocket:

R has markdown (Rmd) and python has Jupyter(lab) notebooks ! I will use Jupyter lab for my analysis. 

With the database created, all we have to do is query the database and begin !

Reproducing results from original paper - [AllTaxa](./JupyterNotebook/AllTaxa.ipynb)

Repeating analysis for bacteria - [Bacteria](./JupyterNotebook/Bacteria.ipynb)

