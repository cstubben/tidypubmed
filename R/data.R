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

#' PubMed articles with multiple databanks and accession numbers
#'
#' @format An character string with 3 articles.
#' @source NCBI PubMed
#' @examples
#' \dontrun{
#' res <- pubmed_search("31566309[PMID] OR 16939956[PMID] OR 30145791[PMID]")
#' dbc <- pubmed_fetch(res, parsed=FALSE)
#' }
#' str(dbc)
#' db <- pubmed_nodeset(dbc)
#' db
#' cat(as.character(db[1]))
"dbc"
