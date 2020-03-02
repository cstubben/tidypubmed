#' Search PubMed
#'
#' Run \code{entrez_search} and return the web history.
#'
#' @param term search term
#'
#' @return A list
#'
#' @examples
#' res <- pubmed_search("aquilegia[TITLE]")
#' res
#' # aq <- pubmed_fetch(res)
#' @export

pubmed_search <- function(term){
   n <- rentrez::entrez_search(db = "pubmed", term = term, use_history = TRUE)
   message(n$count, " results found")
   n
}
