#' Parse authors
#'
#' @param nodes article node set
#'
#' @return A tibble
#'
#' @examples
#' aq <- pubmed_nodeset(aqc)
#' x <- pubmed_authors(aq)
#' x
#' mutate(x, name=paste(last, initials)) %>%
#'   group_by(pmid) %>%
#'   summarize(authors=paste(name, collapse=", "))
#' mutate(x, name=ifelse(lead(n) == 5, "et al", paste(last, initials))) %>%
#'   filter(n < 5) %>%
#'   group_by(pmid) %>%
#'   summarize(authors=paste(name, collapse=", "))
#' @export

pubmed_authors <- function(nodes){
   z <- lapply(nodes, function(x) xml2::xml_find_all(x, ".//Author"))
   x <- lapply(z, function(x) tibble::enframe( xml2::xml_text(xml2::xml_find_first(x, ".//LastName") ), "n", "last"))
   x <- bind_rows(x, .id="pmid")
   x$first <- xml_text_first(z, "//ForeName")
   x$initials <- xml_text_first(z, "//Initials")
   x$orcid <- xml_text_first(z, '//Identifier[@Source="ORCID"]')
   ## some with http
   x$orcid <- gsub("http://orcid.org/", "", x$orcid)
   x$affiliation <-  xml_text_first(z, "//Affiliation")  # 0 to many
   x
}
