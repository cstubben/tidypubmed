#' Parse publication types
#'
#' @param nodes article node set
#'
#' @return A tibble
#'
#' @examples
#' aq <- pubmed_nodeset(aqc)
#' x <- pubmed_pubtypes(aq)
#' x
#' count(x, publication_type, sort=TRUE)
#' @export

pubmed_pubtypes <- function(nodes) {
  
  x <- xml_tidy_text(nodes, ".//PublicationType", label = "publication_type")
  y <- xml_tidy_attr(nodes, ".//PublicationType", attr = "UI", label = "uid")
  if (nrow(x) != nrow(y)) message("WARNING: missing some UI attribute nodes")
  z <- full_join(x, y, by=c("pmid", "n"))
  
  z
}
