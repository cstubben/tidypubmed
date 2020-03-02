#' Fetch PubMed results
#'
#' Run \code{entrez_fetch} and return article nodes
#'
#' @param history web history results from \code{\link{pubmed_search}}
#' @param parsed parse results into article xml_nodeset with PMID names, default TRUE
#'
#' @return A character string or xml_nodeset if parsed=TRUE
#'
#' @examples
#' res <- pubmed_search("aquilegia[TITLE]")
#' aq <- pubmed_fetch(res)
#' aq
#' cat(as.character(aq[1]))
#' @export

pubmed_fetch <- function(history, parsed=TRUE){
   if(class(history)[1] != "esearch") stop("history should be pubmed_search results")
   e1 <- rentrez::entrez_fetch(db="pubmed", web_history=history$web_history, rettype="xml")
   if(parsed){
	   e1 <- pubmed_nodeset(e1)
   }else{
	   message("Saved results as a character string, use pubmed_nodeset to parse into xml_nodeset")
   }
   e1
}
