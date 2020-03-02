
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
devtools::install_github("cstubben/tidypubmed")
```

Search [PubMed](https://www.ncbi.nlm.nih.gov/pubmed/) and download the
results. The two functions are wrappers for `entrez_search` and
`entrez_fetch` in [rentrez](https://github.com/ropensci/rentrez) and
will also parse the results into a `xml_nodeset` with PMID names.

``` r
library(tidypubmed)
res <- pubmed_search("aquilegia[TITLE]")
#  107 results found
aq <- pubmed_fetch(res)
#  Created xml_nodeset with 107 articles
```

The package includes five functions to parse the article nodes.

| R function        | Description         |
| :---------------- | :------------------ |
| `pubmed_table`    | Citation metadata   |
| `pubmed_abstract` | Abstract paragraphs |
| `pubmed_authors`  | Authors             |
| `pubmed_keywords` | Keywords            |
| `pubmed_mesh`     | MeSH terms          |

Parse the authors, year, title, journal and other metadata into a table
with one row per PMID.

``` r
x <- pubmed_table(aq)
x
#  # A tibble: 107 x 15
#        pmid authors    year title   journal volume issue pages pubmodel ppub  epub  pubtype country doi   pii  
#       <int> <chr>     <int> <chr>   <chr>   <chr>  <chr> <chr> <chr>    <chr> <chr> <chr>   <chr>   <chr> <chr>
#   1  3.21e7 Meaders …  2020 Develo… Annals… <NA>   <NA>  <NA>  Print-E… 2020… 2020… Journa… England 10.1… 5739…
#   2  3.19e7 Zhou ZL,…  2019 Cell n… Plant … 41     5     307-… Electro… 2019… 2019… Journa… China   10.1… S246…
#   3  3.18e7 Aköz G, …  2019 The Aq… Genome… 20     1     256   Electro… 2019… 2019… Journa… England 10.1… 10.1…
#   4  3.17e7 Sharma B…  2019 Homolo… Fronti… 10     <NA>  1218  Electro… 2019  2019… Journa… Switze… 10.3… <NA> 
#   5  3.15e7 Sharma B…  2019 Develo… Genes   10     10    <NA>  Electro… 2019… 2019… Journa… Switze… 10.3… gene…
#   6  3.14e7 Ballerin…  2019 Compar… BMC ge… 20     1     668   Electro… 2019… 2019… Compar… England 10.1… 10.1…
#   7  3.08e7 Li MR, W…  2019 Rapid … Genome… 11     3     919-… Print    2019… <NA>  Journa… England 10.1… 5355…
#   8  3.07e7 Groh JS,…  2019 On the… AoB PL… 11     1     ply0… Electro… 2019… 2018… Journa… England 10.1… ply0…
#   9  3.03e7 Filiault…  2018 The Aq… eLife   7      <NA>  <NA>  Electro… 2018… 2018… Journa… England 10.7… 36426
#  10  3.01e7 Min Y, B…  2019 Homolo… The Ne… 221    2     1090… Print-E… 2019… 2018… Journa… England 10.1… <NA> 
#  # … with 97 more rows
count(x, journal, country, sort=TRUE)
#  # A tibble: 55 x 3
#     journal                                               country           n
#     <chr>                                                 <chr>         <int>
#   1 Evolution; international journal of organic evolution United States    10
#   2 Acta poloniae pharmaceutica                           Poland            7
#   3 American journal of botany                            United States     6
#   4 Plant disease                                         United States     6
#   5 The New phytologist                                   England           5
#   6 Annals of botany                                      England           4
#   7 Chemical & pharmaceutical bulletin                    Japan             4
#   8 PloS one                                              United States     4
#   9 Molecular ecology                                     England           3
#  10 Biochemical Society transactions                      England           2
#  # … with 45 more rows
```

Parse the abstracts and combine the label and paragraph into a single
row per article.

``` r
x <- pubmed_abstract(aq)
x
#  # A tibble: 140 x 4
#         pmid paragraph abstract                                                                  label         
#        <int>     <int> <chr>                                                                     <chr>         
#   1 32068783         1 The ranunculid model system Aquilegia is notable for the presence of a f… BACKGROUND AN…
#   2 32068783         2 We used histological techniques to describe the development of the Aquil… METHODS       
#   3 32068783         3 Our developmental study has revealed novel features of staminode develop… KEY RESULTS   
#   4 32068783         4 These findings suggest a model in which the novel staminode identity pro… CONCLUSIONS   
#   5 31934675         1 Variations of nectar spur length allow pollinators to utilize resources … <NA>          
#   6 31779695         1 Whole-genome duplications (WGDs) have dominated the evolutionary history… BACKGROUND    
#   7 31779695         2 Within-genome synteny confirms that columbines are ancient tetraploids, … RESULTS       
#   8 31779695         3 Novel analyses of synteny sharing together with the well-preserved struc… CONCLUSIONS   
#   9 31681357         1 Homologs of the transcription factor LEAFY (LFY) and the F-box family me… <NA>          
#  10 31546687         1 Reproductive success in plants is dependent on many factors but the prec… <NA>          
#  # … with 130 more rows
mutate(x, text=ifelse(is.na(label), abstract, paste0(label, ": ", abstract))) %>%
   group_by(pmid) %>%
   summarize(abstract=paste(text, collapse=" ")) %>%
   arrange(desc(pmid))
#  # A tibble: 96 x 2
#         pmid abstract                                                                                          
#        <int> <chr>                                                                                             
#   1 32068783 BACKGROUND AND AIMS: The ranunculid model system Aquilegia is notable for the presence of a fifth…
#   2 31934675 Variations of nectar spur length allow pollinators to utilize resources in novel ways, leading to…
#   3 31779695 BACKGROUND: Whole-genome duplications (WGDs) have dominated the evolutionary history of plants. O…
#   4 31681357 Homologs of the transcription factor LEAFY (LFY) and the F-box family member UNUSUAL FLORAL ORGAN…
#   5 31546687 Reproductive success in plants is dependent on many factors but the precise timing of flowering i…
#   6 31438840 BACKGROUND: Petal nectar spurs, which facilitate pollination through animal attraction and pollen…
#   7 30861746 Eryngium amethystinum (amethyst sea holly) is a herbaceous plant commonly grown as an ornamental …
#   8 30812597 Aquilegia flabellata Sieb. and Zucc. (columbine) is a perennial garden species belonging to the f…
#   9 30793209 Elucidating the mechanisms underlying the genetic divergence between closely related species is c…
#  10 30764246 Aquilegia flabellata (Ranunculaceae), fan columbine, is a perennial herbaceous plant with brillia…
#  # … with 86 more rows
```

Optionally, use the
[tokenizers](https://lincolnmullen.com/software/tokenizers/) package to
split abstract paragraphs into sentences.

``` r
pubmed_abstract(aq, sentence=TRUE)
#  # A tibble: 946 x 5
#         pmid paragraph sentence abstract                                                          label        
#        <int>     <int>    <int> <chr>                                                             <chr>        
#   1 32068783         1        1 The ranunculid model system Aquilegia is notable for the presenc… BACKGROUND A…
#   2 32068783         1        2 Previous studies have found that the genetic basis for the ident… BACKGROUND A…
#   3 32068783         2        1 We used histological techniques to describe the development of t… METHODS      
#   4 32068783         2        2 These results have been compared to four other Aquilegia species… METHODS      
#   5 32068783         2        3 As a complement, RNA-seq has been conducted at two developmental… METHODS      
#   6 32068783         3        1 Our developmental study has revealed novel features of staminode… KEY RESULTS  
#   7 32068783         3        2 In addition, patterns of abaxial/adaxial differentiation are obs… KEY RESULTS  
#   8 32068783         3        3 The comparative transcriptomics are consistent with the observed… KEY RESULTS  
#   9 32068783         4        1 These findings suggest a model in which the novel staminode iden… CONCLUSIONS  
#  10 32068783         4        2 While the ecological function of Aquilegia staminodes remains to… CONCLUSIONS  
#  # … with 936 more rows
```

List the authors and first affliation. Group the authors by PMID and
replace five or more names with et al. The untidy author string is also
included the in `pubmed_table` above.

``` r
x <- pubmed_authors(aq)
x
#  # A tibble: 406 x 7
#         pmid     n last    first    initials orcid affiliation                                                 
#        <int> <int> <chr>   <chr>    <chr>    <chr> <chr>                                                       
#   1 32068783     1 Meaders Clara    C        <NA>  Department of Organismic and Evolutionary Biology, Harvard …
#   2 32068783     2 Min     Ya       Y        <NA>  Department of Organismic and Evolutionary Biology, Harvard …
#   3 32068783     3 Freedb… Katheri… KJ       <NA>  Department of Organismic and Evolutionary Biology, Harvard …
#   4 32068783     4 Kramer  Elena    E        <NA>  Department of Organismic and Evolutionary Biology, Harvard …
#   5 31934675     1 Zhou    Zhi-Li   ZL       <NA>  Institute of Tibetan Plateau Research at Kunming, Kunming I…
#   6 31934675     2 Duan    Yuan-Wen YW       <NA>  Institute of Tibetan Plateau Research at Kunming, Kunming I…
#   7 31934675     3 Luo     Yan      Y        <NA>  Gardening and Horticulture Department, Xishuangbanna Tropic…
#   8 31934675     4 Yang    Yong-Pi… YP       <NA>  Institute of Tibetan Plateau Research at Kunming, Kunming I…
#   9 31934675     5 Zhang   Zhi-Qia… ZQ       <NA>  Laboratory of Ecology and Evolutionary Biology, Yunnan Univ…
#  10 31779695     1 Aköz    Gökçe    G        <NA>  Gregor Mendel Institute, Austrian Academy of Sciences, Vien…
#  # … with 396 more rows
mutate(x, name=ifelse(lead(n) == 5, "et al", paste(last, initials))) %>%
   filter(n < 5) %>%
   group_by(pmid) %>%
   summarize(authors=paste(name, collapse=", "))
#  # A tibble: 107 x 2
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
#  # … with 97 more rows
```

Group the keywords into a long character string.

``` r
x <- pubmed_keywords(aq)
x
#  # A tibble: 144 x 4
#         pmid     n majortopic keyword                
#        <int> <int> <chr>      <chr>                  
#   1 32068783     1 N          Aquilegia              
#   2 32068783     2 N          floral organ identity  
#   3 32068783     3 N          novelty                
#   4 32068783     4 N          staminode              
#   5 31934675     1 N          Aquilegia rockii       
#   6 31934675     2 N          Cell number            
#   7 31934675     3 N          Columbine              
#   8 31934675     4 N          Floral polymorphism    
#   9 31934675     5 N          Intraspecific variation
#  10 31934675     6 N          Nectar spur            
#  # … with 134 more rows
arrange(x, pmid, keyword) %>%
  group_by(pmid) %>%
  summarize(keywords= paste(keyword, collapse=", ")) %>%
  arrange(desc(pmid))
#  # A tibble: 25 x 2
#         pmid keywords                                                                                          
#        <int> <chr>                                                                                             
#   1 32068783 Aquilegia, floral organ identity, novelty, staminode                                              
#   2 31934675 Aquilegia rockii, Cell number, Columbine, Floral polymorphism, Intraspecific variation, Nectar sp…
#   3 31681357 Aquilegia, floral meristem identity, inflorescence structure, leafy, unusual floral organs        
#   4 31546687 Aquilegia, floral meristem, flowering, flowering locus t, genetic pathways, inflorescence meriste…
#   5 31438840 Aquilegia, Diversification, Evolution, Gene expression, Nectar spur, Petal development, RNAseq    
#   6 30793209 adaptation, Aquilegia, ecological specialization, selection, speciation                           
#   7 30687492 Aquilegia, genetic swamping, herbarium, hybridization, introgression, range boundaries            
#   8 30325307 Aquilegia, chromosome evolution, chromosomes, gene expression, genetics, genome evolution, genomi…
#   9 30145791 Aquilegia, co-option, nectary development, style development, stylish                             
#  10 30047083 Aquilegia viridiflora, Gram-positive, Leifsonia flava sp. nov., polyphasic taxonomy, rhizosphere  
#  # … with 15 more rows
```

Count the MeSH terms.

``` r
# x <- pubmed_keywords(aq)
x <- pubmed_mesh(aq)
x
#  # A tibble: 937 x 6
#         pmid     n descriptor                qualifier            majortopic mesh                           
#        <int> <int> <chr>                     <chr>                <chr>      <chr>                          
#   1 31438840     1 Aquilegia                 genetics             Y          Aquilegia/genetics*            
#   2 31438840     1 Aquilegia                 growth & development Y          Aquilegia/growth & development*
#   3 31438840     2 Flowers                   genetics             Y          Flowers/genetics*              
#   4 31438840     2 Flowers                   growth & development Y          Flowers/growth & development*  
#   5 31438840     3 Gene Expression Profiling <NA>                 Y          Gene Expression Profiling*     
#   6 31438840     4 Genes, Plant              genetics             Y          Genes, Plant/genetics*         
#   7 31438840     5 Plant Nectar              metabolism           Y          Plant Nectar/metabolism*       
#   8 30793209     1 Adaptation, Biological    <NA>                 N          Adaptation, Biological         
#   9 30793209     2 Aquilegia                 genetics             Y          Aquilegia/genetics*            
#  10 30793209     3 Biological Evolution      <NA>                 Y          Biological Evolution*          
#  # … with 927 more rows
mutate(x, mesh=gsub("\\*", "", mesh)) %>%
  count(mesh, sort=TRUE)
#  # A tibble: 470 x 2
#     mesh                                  n
#     <chr>                             <int>
#   1 Aquilegia/genetics                   29
#   2 Animals                              12
#   3 Plant Extracts/pharmacology          12
#   4 Aquilegia/chemistry                  11
#   5 Flowers/genetics                     11
#   6 Gene Expression Regulation, Plant    11
#   7 Aquilegia                             9
#   8 Aquilegia/growth & development        9
#   9 Aquilegia/metabolism                  9
#  10 Evolution, Molecular                  9
#  # … with 460 more rows
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
#      <PMID Version="1">32068783</PMID>
#      <DateRevised>
#        <Year>2020</Year>
#        <Month>02</Month>
#        <Day>18</Day>
#      </DateRevised>
#      <Article PubModel="Print-Electronic">
#        <Journal>
#          <ISSN IssnType="Electronic">1095-8290</ISSN>
#          <JournalIssue CitedMedium="Internet">
#            <PubDate>
#              <Year>2020</Year>
#              <Month>Feb</Month>
#              <Day>18</Day>
#            </PubDate>
#          </JournalIssue>
#          <Title>Annals of botany</Title>
#          <ISOAbbreviation>Ann. Bot.</ISOAbbreviation>
#        </Journal>
#        <ArticleTitle>Developmental and molecular characterization of novel staminodes in Aquilegia.</ArticleTitle>
#        <ELocationID EIdType=
```

Parse a specific node using the helper function `xml_tidy_text` and an
xpath expression.

``` r
xml_tidy_text(aq, "//Chemical/NameOfSubstance", "chemical")
#  # A tibble: 220 x 3
#         pmid     n chemical            
#        <int> <int> <chr>               
#   1 31438840     1 Plant Nectar        
#   2 30145791     1 Plant Nectar        
#   3 30047083     1 DNA, Bacterial      
#   4 30047083     2 DNA, Ribosomal      
#   5 30047083     3 Fatty Acids         
#   6 30047083     4 Peptidoglycan       
#   7 30047083     5 Phospholipids       
#   8 30047083     6 Pigments, Biological
#   9 30047083     7 RNA, Ribosomal, 16S 
#  10 30047083     8 Vitamin K 2         
#  # … with 210 more rows

xml_tidy_text(aq, "//Reference//ArticleId[@IdType='pubmed']", "cited")
#  # A tibble: 1,022 x 3
#         pmid     n cited   
#        <int> <int> <chr>   
#   1 31934675     1 16284709
#   2 31934675     2 26800256
#   3 31934675     3 20497348
#   4 31934675     4 25063469
#   5 31934675     5 18223038
#   6 31934675     6 26779209
#   7 31934675     7 17526522
#   8 31934675     8 21790812
#   9 31934675     9 19910308
#  10 31934675    10 22388286
#  # … with 1,012 more rows
```
