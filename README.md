# popular_gene
Trying to recreate article The most popular genes in the human genome (https://www.nature.com/articles/d41586-017-07291-9) for prokaryotes (bacteria)

**Why ?**
I am a python newbie, but not new to programming overall, I am good with R, Perl and have an undiagnosed OCD of trying to write efficient one-liners in shell for small jobs ;-)
R was self-taught and I came to realize pretty early on that when it comes to programming, 
  > reading basics only takes you so far ... pick up a project and learn along the way !

### Step1 - Fork it !

#### Make sure that the forked repo can be synced with the original repo

### Step2 - creating a safe environment for play aka Conda !

### Step  Follow the instructions

Get list of citations by date

`python scripts/pmids_by_date.py --startdate 1990/01/01 --enddate 2017/11/05`

:interrobang: Hiccup 1 :interrobang:
`FileNotFoundError: [Errno 2] No such file or directory: './data/pmid_by_date/1990_01_02.ssv'`

####Troubleshooting 101 - Look at the damned code 

At first glance, one obvious mistake appeared to be that I was not specifying the `--output-dir` parameter for the script. However that didn't solve the issue. The error just changed to now include the outdir path I provided . So the issue was not that I didn't give that option (since from the code it is obvious that it should default to `./data/pmid_by_date`). 

:zap: Turns out that python can't just create paths willy nilly unless you specifically ask it to do so ! Simple Googling and ol faithful [Stackoverflow](https://stackoverflow.com/questions/12517451/automatically-creating-directories-with-file-output) helped solve the issue.

Code edited (changed commited and pushed on github), 
```python
import os
os.makedirs(os.path.dirname(filename), exist_ok=True)
```

Lets try again

`python gene-citation-counts/scripts/pmids_by_date.py --startdate 1990/01/01 --enddate 2017/11/05`

:tada: **it worked !!**


