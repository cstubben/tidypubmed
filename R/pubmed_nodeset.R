#' Parse PubMed into xml_nodeset with PMID names
#'
#' @param esearch a character string from \code{link{pubmed_search}}
#'
#' @return A xml_nodeset
#'
#' @examples
#' \dontrun{
#' res <- pubmed_search("aquilegia[TITLE]")
#' aqc <- pubmed_fetch(res, parsed=FALSE)
#' }
#' aq <- pubmed_nodeset(aqc)
#' aq
#' cat(as.character(aq[1]))
#' @export

pubmed_nodeset <- function(esearch){
     doc <- xml2::read_xml(esearch)
     nodes <- xml2::xml_find_all(doc, "//PubmedArticle")
     ids <- sapply(nodes, function(x) xml2::xml_text(xml2::xml_find_first(x, ".//MedlineCitation/PMID")))
     names(nodes) <- ids
     message("Created xml_nodeset with ", length(ids), " articles")
	 nodes
}
