#' Parse article metadata
#'
#' @param nodes article node set
#' @param etal shorten author string, default false
#' @param iso use journal ISO abbreviation, default false
#'
#' @return A tibble
#'
#' @examples
#' aq <- pubmed_nodeset(aqc)
#' x <- pubmed_table(aq)
#' x
#' @export

pubmed_table <- function(nodes, etal=FALSE, iso=FALSE){
   # title
   x <- xml_tidy_text(nodes, "//ArticleTitle", "title")
   x$title <- gsub("\\.$", "", x$title)
   # x$n <- 1:nrow(x)
   # authors
   if(etal){
	   aut <- pubmed_authors(nodes) %>%
       mutate(name=ifelse(lead(n) == 5, "et al", paste(last, initials))) %>%
       filter(n < 5) %>%
       group_by(pmid) %>%
       summarize(authors=paste(name, collapse=", "))
   }else{
      aut <- pubmed_authors(nodes) %>%
        mutate(name=paste(last, initials)) %>%
        group_by(pmid) %>%
        summarize(authors=paste(name, collapse=", "))
   }
   x <- inner_join(x, aut, by="pmid")
   ## pub dates
   ppub <- sapply(nodes, function(x) paste( xml2::xml_text(xml2::xml_find_all(x, ".//PubDate/*")), collapse="-"))
   x$year <- as.integer(substr(ppub, 1,4))
   x <- x[, c(1,4,5,3)]
   # journal
   if(iso){
     x$journal <- xml_text_first(nodes, "//Journal/ISOAbbreviation")
   }else{
     x$journal <- xml_text_first(nodes, "//Journal/Title")
   }
   x$volume  <- xml_text_first(nodes, "//JournalIssue/Volume")
   x$issue  <- xml_text_first(nodes, "//JournalIssue/Issue")
   x$pages <- xml_text_first(nodes, "//MedlinePgn")
   x$pubmodel <- xml_attr_first(nodes, "//Article", "PubModel")
   # print pub
   x$ppub <- ppub
   # epub dates
   epub <- sapply(nodes, function(x) paste( xml2::xml_text(xml2::xml_find_all(x, ".//ArticleDate/*")), collapse="-"))
   epub[epub==""]<-NA
   x$epub <- epub
   x$pubtype <- xml_text_first(nodes, "//PublicationType")
   x$country <- xml_text_first(nodes, "//MedlineJournalInfo/Country")
   x$doi <- xml_text_first(nodes, '//ArticleId[@IdType="doi"]')
   x$pii <- xml_text_first(nodes, '//ArticleId[@IdType="pii"]')
   x$pmid <- as.integer(x$pmid)
   x
}
