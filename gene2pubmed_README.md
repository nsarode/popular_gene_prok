===========================================================================
gene2pubmed                                     recalculated daily
---------------------------------------------------------------------------
           This file can be considered as the logical equivalent of
           what is reported as Gene/PubMed Links visible in Gene's 
           and PubMed's Links menus. Although gene2pubmed is re-calculated daily,
           some of the source documents (GeneRIFs, for example) are not
           updated that frequently, so timing depends on the update
           frequency of the data source.

           Documentation about how these links are maintained
           is provided here:

           https://www.ncbi.nlm.nih.gov/entrez/query/static/entrezlinks.html#gene

           tab-delimited
           one line per set of tax_id/GeneID/PMID
           Column header line is the first line in the file.
---------------------------------------------------------------------------

tax_id:
           the unique identifier provided by NCBI Taxonomy
           for the species or strain/isolate

GeneID:
           the unique identifier for a gene


PubMed ID (PMID):
           the unique identifier in PubMed for a citation


===========================================================================
