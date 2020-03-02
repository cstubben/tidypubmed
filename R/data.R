#' Aquilegia search results
#'
#' @format An character string with 107 articles.
#' @source NCBI PubMed
#' @examples
#' \dontrun{
#' res <- pubmed_search("aquilegia[TITLE]")
#' aqc <- pubmed_fetch(res, parsed=FALSE)
#' }
#' str(aqc)
#' aq <- pubmed_nodeset(aqc)
#' aq
#' cat(as.character(aq[1]))
"aqc"
