
# tidypubmed

The [PubMed](https://www.ncbi.nlm.nih.gov/pubmed/) database at NCBI
includes 30 million citations from biomedical and life sciences
journals. The abstracts and article metadata are easy to search using
the [rentrez](https://github.com/ropensci/rentrez) package, but parsing
the [PubMed
XML](https://www.nlm.nih.gov/bsd/licensee/elements_descriptions.html)
can be challenging. The `tidypubmed` package uses the
[xml2](https://github.com/r-lib/xml2) package to parse abstracts, MeSH
terms, keywords, authors and citation details into
[tidy](https://r4ds.had.co.nz/tidy-data.html) datasets.

## Installation

Use [devtools](https://github.com/r-lib/devtools) to install the
package.

``` r
devtools::install_github("maia-sh/tidypubmed")
```

Search [PubMed](https://www.ncbi.nlm.nih.gov/pubmed/) and download the
results. The two functions are wrappers for `entrez_search` and
`entrez_fetch` in [rentrez](https://github.com/ropensci/rentrez) and
will also parse the results into a `xml_nodeset` with PMID names.

``` r
library(tidypubmed)
#  Loading required package: dplyr
#  Warning: package 'dplyr' was built under R version 4.1.2
#  
#  Attaching package: 'dplyr'
#  The following objects are masked from 'package:stats':
#  
#      filter, lag
#  The following objects are masked from 'package:base':
#  
#      intersect, setdiff, setequal, union
res <- pubmed_search("aquilegia[TITLE]")
#  127 results found
aq <- pubmed_fetch(res)
#  Created xml_nodeset with 127 articles
```

Alternatively, you can download the raw xml and save to disk.

``` r
download_pubmed(99999999,
                dir = here::here("data", "raw", "pubmed"),
                api_key = keyring::key_get("ncbi-pubmed")
)
```

You can use `purrr::walk` to download many records.

``` r
purrr::walk(download_pubmed,
            dir = here::here("data", "raw", "pubmed"),
            api_key = keyring::key_get("ncbi-pubmed")
)
```

The package includes six functions to parse the article nodes.

| R function         | Description         |
|:-------------------|:--------------------|
| `pubmed_table`     | Citation metadata   |
| `pubmed_abstract`  | Abstract paragraphs |
| `pubmed_authors`   | Authors             |
| `pubmed_keywords`  | Keywords            |
| `pubmed_mesh`      | MeSH terms          |
| `pubmed_databanks` | Databanks           |
| `pubmed_pubtypes`  | Publication types   |

The package includes a wrapper function to parse a specified article
node types from a single PubMed record. Similar to downloading, you can
use `purrr::map_dfr` to parse many records.

``` r
extract_pubmed(filepath =  = here::here("data", "raw", "pubmed", "99999999.xml"),
               datatype = "main", # one of c("main", "abstract", "databanks", "authors", "mesh", "keywords", "pubtypes"). "main" indicated `pubmed_table`
)

here::here("data", "raw", "pubmed") %>% 
  fs::dir_ls() %>% 
  purrr::map_dfr(extract_pubmed, datatype = "main")
```

Parse the authors, year, title, journal and other metadata into a table
with one row per PMID.

``` r
x <- pubmed_table(aq)
x
#  # A tibble: 127 × 16
#         pmid authors     year title journal volume issue pages pubmodel ppub  epub  pubtype country doi   pii  
#        <int> <chr>      <int> <chr> <chr>   <chr>  <chr> <chr> <chr>    <chr> <chr> <chr>   <chr>   <chr> <chr>
#   1 35176226 Cabin Z, …  2022 Non-… Curren… <NA>   <NA>  <NA>  Print-E… 2022… 2022… Journa… England 10.1… S096…
#   2 35175330 Min Y, Co…  2022 Quan… Develo… 149    4     <NA>  Print-E… 2022… 2022… Journa… England 10.1… 2743…
#   3 35039842 Yang S, W…  2022 Char… Hortic… <NA>   <NA>  <NA>  Print-E… 2022… 2022… Journa… England 10.1… 6510…
#   4 34508638 Conway SJ…  2021 Bras… Annals… 128    7     931-… Print    2021… <NA>  Journa… England 10.1… 6368…
#   5 34457112 Jan H, Sh…  2021 Plan… Oxidat… 2021   <NA>  4786… Electro… 2021  2021… Journa… United… 10.1… <NA> 
#   6 34448283 Xue C, Ge…  2021 Dive… Molecu… 30     22    5796… Print-E… 2021… 2021… Journa… England 10.1… <NA> 
#   7 34270789 Edwards M…  2021 Gene… Evolut… 75     9     2197… Print-E… 2021… 2021… Journa… United… 10.1… <NA> 
#   8 34098912 Jan H, Us…  2021 Phyt… BMC co… 21     1     165   Electro… 2021… 2021… Journa… England 10.1… 10.1…
#   9 33888127 Wang HY, …  2021 Opti… BMC ch… 15     1     26    Electro… 2021… 2021… Journa… Switze… 10.1… 10.1…
#  10 33854846 Zhang W, …  2021 Comp… Applic… 9      3     e114… Electro… 2021… 2021… Journa… United… 10.1… APS3…
#  # … with 117 more rows, and 1 more variable: pmc <chr>
count(x, journal, country, sort=TRUE)
#  # A tibble: 66 × 3
#     journal                                               country           n
#     <chr>                                                 <chr>         <int>
#   1 Evolution; international journal of organic evolution United States    11
#   2 Acta poloniae pharmaceutica                           Poland            7
#   3 The New phytologist                                   England           7
#   4 American journal of botany                            United States     6
#   5 Plant disease                                         United States     6
#   6 Annals of botany                                      England           5
#   7 Chemical & pharmaceutical bulletin                    Japan             4
#   8 Molecular ecology                                     England           4
#   9 PloS one                                              United States     4
#  10 Genome biology                                        England           3
#  # … with 56 more rows
```

Parse the abstracts and combine the label and paragraph into a single
row per article.

``` r
x <- pubmed_abstract(aq)
x
#  # A tibble: 170 × 4
#         pmid paragraph abstract                                                                           label
#        <int>     <int> <chr>                                                                              <chr>
#   1 35176226         1 Here, we describe a polymorphic population of Aquilegia coerulea with a naturally… <NA> 
#   2 35175330         1 In-depth investigation of any developmental process in plants requires knowledge … <NA> 
#   3 35039842         1 There are several causes for the great diversity in floral terpenes. The terpene … <NA> 
#   4 34508638         1 Aquilegia produce elongated, three-dimensional petal spurs that fill with nectar … BACK…
#   5 34508638         2 We exogenously applied the biologically active brassinosteroid brassinolide to de… METH…
#   6 34508638         3 We identified a total of three Aquilegia homologues of the BES1/BZR1 protein fami… KEY …
#   7 34508638         4 Collectively, our results support a role for brassinosteroids in anisotropic cell… CONC…
#   8 34457112         1 The anti-cancer, anti-aging, anti-inflammatory, antioxidant, and anti-diabetic ef… <NA> 
#   9 34448283         1 Quaternary climate oscillations and geographical heterogeneity play important rol… <NA> 
#  10 34270789         1 Interactions with animal pollinators have helped shape the stunning diversity of … <NA> 
#  # … with 160 more rows
mutate(x, text=ifelse(is.na(label), abstract, paste0(label, ": ", abstract))) %>%
  group_by(pmid) %>%
  summarize(abstract=paste(text, collapse=" ")) %>%
  arrange(desc(pmid))
#  # A tibble: 114 × 2
#         pmid abstract                                                                                          
#        <int> <chr>                                                                                             
#   1 35176226 Here, we describe a polymorphic population of Aquilegia coerulea with a naturally occurring flora…
#   2 35175330 In-depth investigation of any developmental process in plants requires knowledge of both the unde…
#   3 35039842 There are several causes for the great diversity in floral terpenes. The terpene products are det…
#   4 34508638 BACKGROUND AND AIMS: Aquilegia produce elongated, three-dimensional petal spurs that fill with ne…
#   5 34457112 The anti-cancer, anti-aging, anti-inflammatory, antioxidant, and anti-diabetic effects of zinc ox…
#   6 34448283 Quaternary climate oscillations and geographical heterogeneity play important roles in determinin…
#   7 34270789 Interactions with animal pollinators have helped shape the stunning diversity of flower morpholog…
#   8 34098912 BACKGROUND: Himalayan Columbine (Aquilegia pubiflora Wall. Ex Royle) is a medicinal plant and hav…
#   9 33888127 BACKGROUND: The floral scents of plants play a key role in plant reproduction through the communi…
#  10 33854846 Premise: Aquilegia is an ideal taxon for studying the evolution of adaptive radiation. Current ph…
#  # … with 104 more rows
```

Optionally, use the
[tokenizers](https://lincolnmullen.com/software/tokenizers/) package to
split abstract paragraphs into sentences.

``` r
pubmed_abstract(aq, sentence=TRUE)
#  # A tibble: 1,094 × 5
#         pmid paragraph sentence abstract                                                                  label
#        <int>     <int>    <int> <chr>                                                                     <chr>
#   1 35176226         1        1 Here, we describe a polymorphic population of Aquilegia coerulea with a … <NA> 
#   2 35176226         1        2 Although it would be expected that this loss of pollinator reward would … <NA> 
#   3 35176226         1        3 We identify the underlying locus (APETALA3-3) and multiple causal loss-o… <NA> 
#   4 35176226         1        4 Elevated linkage disequilibrium around the two most common causal allele… <NA> 
#   5 35176226         1        5 Lastly, genotypic frequencies at AqAP3-3 indicate a degree of positive a… <NA> 
#   6 35176226         1        6 Together, these data provide both a compelling example that large-scale … <NA> 
#   7 35175330         1        1 In-depth investigation of any developmental process in plants requires k… <NA> 
#   8 35175330         1        2 Floral meristems (FMs) produce floral organs, after which they undergo f… <NA> 
#   9 35175330         1        3 Using live confocal imaging, we characterized developmental dynamics dur… <NA> 
#  10 35175330         1        4 Our results uncover distinct patterns of primordium initiation between s… <NA> 
#  # … with 1,084 more rows
```

List the authors and first affiliation and then replace five or more
names with et al. The untidy author string is also included in the
`pubmed_table` above.

``` r
x <- pubmed_authors(aq)
x
#  # A tibble: 529 × 7
#         pmid     n last      first       initials orcid               affiliation                              
#        <int> <int> <chr>     <chr>       <chr>    <chr>               <chr>                                    
#   1 35176226     1 Cabin     Zachary     Z        <NA>                Department of Ecology, Evolution, and Ma…
#   2 35176226     2 Derieg    Nathan J    NJ       <NA>                Department of Ecology, Evolution, and Ma…
#   3 35176226     3 Garton    Alexandra   A        <NA>                Department of Ecology, Evolution, and Ma…
#   4 35176226     4 Ngo       Timothy     T        <NA>                Department of Ecology, Evolution, and Ma…
#   5 35176226     5 Quezada   Ashley      A        <NA>                Department of Ecology, Evolution, and Ma…
#   6 35176226     6 Gasseholm Constantine C        <NA>                Department of Ecology, Evolution, and Ma…
#   7 35176226     7 Simon     Mark        M        <NA>                Department of Ecology, Evolution, and Ma…
#   8 35176226     8 Hodges    Scott A     SA       <NA>                Department of Ecology, Evolution, and Ma…
#   9 35175330     1 Min       Ya          Y        0000-0002-7526-4516 Department of Organismic and Evolutionar…
#  10 35175330     2 Conway    Stephanie J SJ       0000-0001-5058-6669 Department of Organismic and Evolutionar…
#  # … with 519 more rows
mutate(x, name=ifelse(lead(n) == 5, "et al", paste(last, initials))) %>%
  filter(n < 5) %>%
  group_by(pmid) %>%
  summarize(authors=paste(name, collapse=", "))
#  # A tibble: 127 × 2
#         pmid authors                                        
#        <int> <chr>                                          
#   1  5918541 Constantine GH, Vitek MR, Sheth K, et al       
#   2  8146145 Hodges SA, Arnold ML                           
#   3  9511461 Bylka W, Matławska I                           
#   4  9511462 Bylka W, Matławska I                           
#   5 10383672 Routley MB, Mavraganis K, Eckert CG            
#   6 10438199 Yoshimitsu H, Nishidas M, Hashimoto F, Nohara T
#   7 10991895 Griffin SR, Mavraganis K, Eckert CG            
#   8 11170673 Chen SB, Gao GY, Leung HW, et al               
#   9 11171154 Longman AJ, Michaelson LV, Sayanova O, et al   
#  10 11607343 Grant V                                        
#  # … with 117 more rows
```

Check the keywords.

``` r
x <- pubmed_keywords(aq)
x
#  # A tibble: 224 × 4
#         pmid     n majortopic keyword                
#        <int> <int> <chr>      <chr>                  
#   1 35176226     1 N          APETALA3-3             
#   2 35176226     2 N          assortative mating     
#   3 35176226     3 N          discontinuous variation
#   4 35176226     4 N          eco-evo-devo           
#   5 35176226     5 N          floral development     
#   6 35176226     6 N          herbivory              
#   7 35176226     7 N          homeotic mutant        
#   8 35176226     8 N          hopeful monster        
#   9 35176226     9 N          positive selection     
#  10 35176226    10 N          soft sweep             
#  # … with 214 more rows
```

Count the MeSH terms.

``` r
x <- pubmed_mesh(aq)
x
#  # A tibble: 1,058 × 6
#         pmid     n descriptor                        qualifier    majortopic mesh                              
#        <int> <int> <chr>                             <chr>        <chr>      <chr>                             
#   1 34508638     1 Aquilegia                         <NA>         Y          Aquilegia*                        
#   2 34508638     2 Brassinosteroids                  <NA>         N          Brassinosteroids                  
#   3 34508638     3 Cell Division                     <NA>         N          Cell Division                     
#   4 34508638     4 Flowers                           <NA>         N          Flowers                           
#   5 34508638     5 Gene Expression Regulation, Plant <NA>         N          Gene Expression Regulation, Plant 
#   6 34508638     6 Plant Nectar                      <NA>         N          Plant Nectar                      
#   7 34457112     1 Anti-Inflammatory Agents          pharmacology N          Anti-Inflammatory Agents/pharmaco…
#   8 34457112     2 Antineoplastic Agents             pharmacology Y          Antineoplastic Agents/pharmacolog…
#   9 34457112     3 Antioxidants                      pharmacology N          Antioxidants/pharmacology         
#  10 34457112     4 Aquilegia                         chemistry    Y          Aquilegia/chemistry*              
#  # … with 1,048 more rows
mutate(x, mesh=gsub("\\*", "", mesh)) %>%
  count(mesh, sort=TRUE)
#  # A tibble: 512 × 2
#     mesh                                  n
#     <chr>                             <int>
#   1 Aquilegia/genetics                   38
#   2 Flowers/genetics                     16
#   3 Gene Expression Regulation, Plant    15
#   4 Plant Extracts/pharmacology          14
#   5 Animals                              13
#   6 Aquilegia                            13
#   7 Aquilegia/chemistry                  13
#   8 Aquilegia/growth & development       11
#   9 Phylogeny                            11
#  10 Aquilegia/metabolism                 10
#  # … with 502 more rows
```

Inspect databanks.

``` r
x <- pubmed_databanks(aq)
x
#  # A tibble: 6 × 5
#        pmid n_databank databank   n_accession_number accession_number   
#       <int>      <int> <chr>                   <int> <chr>              
#  1 30145791          1 GENBANK                     1 MH638630           
#  2 30145791          1 GENBANK                     2 MH638642           
#  3 25673682          1 BioProject                  1 PRJNA270946        
#  4 25314338          1 Dryad                       1 10.5061/dryad.SJ3VP
#  5 17400892          1 GENBANK                     1 EF489475           
#  6 17400892          1 GENBANK                     2 EF489476
count(x, pmid, databank, sort=TRUE)
#  # A tibble: 4 × 3
#        pmid databank       n
#       <int> <chr>      <int>
#  1 17400892 GENBANK        2
#  2 30145791 GENBANK        2
#  3 25314338 Dryad          1
#  4 25673682 BioProject     1
```

Inspect publication types.

``` r
x <- pubmed_pubtypes(aq)
x
#  # A tibble: 217 × 4
#         pmid     n publication_type                         uid    
#        <int> <int> <chr>                                    <chr>  
#   1 35176226     1 Journal Article                          D016428
#   2 35175330     1 Journal Article                          D016428
#   3 35039842     1 Journal Article                          D016428
#   4 34508638     1 Journal Article                          D016428
#   5 34508638     2 Research Support, U.S. Gov't, Non-P.H.S. D013486
#   6 34457112     1 Journal Article                          D016428
#   7 34448283     1 Journal Article                          D016428
#   8 34448283     2 Research Support, Non-U.S. Gov't         D013485
#   9 34270789     1 Journal Article                          D016428
#  10 34270789     2 Research Support, N.I.H., Extramural     D052061
#  # … with 207 more rows
count(x, publication_type, sort=TRUE)
#  # A tibble: 10 × 2
#     publication_type                             n
#     <chr>                                    <int>
#   1 Journal Article                            123
#   2 Research Support, Non-U.S. Gov't            45
#   3 Research Support, U.S. Gov't, Non-P.H.S.    24
#   4 Comparative Study                           10
#   5 Research Support, N.I.H., Extramural         6
#   6 Letter                                       3
#   7 Comment                                      2
#   8 Review                                       2
#   9 English Abstract                             1
#  10 Published Erratum                            1
```

There are an number of additional nodes that can be parsed in the
[PubMed
XML](https://www.nlm.nih.gov/bsd/licensee/elements_descriptions.html).
Use `cat(as.character)` to view a single article (truncated below).

``` r
# cat(as.character(aq[1]))
cat(substr(as.character(aq[1]),1,770))
#  <PubmedArticle>
#    <MedlineCitation Status="Publisher" Owner="NLM">
#      <PMID Version="1">35176226</PMID>
#      <DateRevised>
#        <Year>2022</Year>
#        <Month>02</Month>
#        <Day>17</Day>
#      </DateRevised>
#      <Article PubModel="Print-Electronic">
#        <Journal>
#          <ISSN IssnType="Electronic">1879-0445</ISSN>
#          <JournalIssue CitedMedium="Internet">
#            <PubDate>
#              <Year>2022</Year>
#              <Month>Feb</Month>
#              <Day>11</Day>
#            </PubDate>
#          </JournalIssue>
#          <Title>Current biology : CB</Title>
#          <ISOAbbreviation>Curr Biol</ISOAbbreviation>
#        </Journal>
#        <ArticleTitle>Non-pollinator selection for a floral homeotic mutant conferring loss of nectar reward in Aquilegia coerulea.</Articl
```

Parse a specific node using the helper function `xml_tidy_text` and an
xpath expression.

``` r
xml_tidy_text(aq, "//Chemical/NameOfSubstance", "chemical")
#  # A tibble: 243 × 3
#         pmid     n chemical                 
#        <int> <int> <chr>                    
#   1 34508638     1 Brassinosteroids         
#   2 34508638     2 Plant Nectar             
#   3 34457112     1 Anti-Inflammatory Agents 
#   4 34457112     2 Antineoplastic Agents    
#   5 34457112     3 Antioxidants             
#   6 34457112     4 Cholinesterase Inhibitors
#   7 34457112     5 Hypoglycemic Agents      
#   8 34457112     6 Plant Extracts           
#   9 34457112     7 Reactive Oxygen Species  
#  10 34457112     8 Zinc Oxide               
#  # … with 233 more rows

xml_tidy_text(aq, "//Reference//ArticleId[@IdType='pubmed']", "cited")
#  # A tibble: 1,729 × 3
#         pmid     n cited   
#        <int> <int> <chr>   
#   1 35039842     1 19575583
#   2 35039842     2 21574138
#   3 35039842     3 22907771
#   4 35039842     4 12623068
#   5 35039842     5 17554306
#   6 35039842     6 15918888
#   7 35039842     7 33036280
#   8 35039842     8 26062733
#   9 35039842     9 23256150
#  10 35039842    10 22090381
#  # … with 1,719 more rows
```
