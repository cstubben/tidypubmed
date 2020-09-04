#' Parse databanks
#'
#' @param nodes article node set
#'
#' @return A tibble
#'
#' @examples
#' aq <- pubmed_nodeset(aqc)
#' x <- pubmed_databanks(aq)
#' x
#' count(x, pmid, databank, sort=TRUE)
#' 
#' db <- pubmed_nodeset(dbc)
#' y <- pubmed_databanks(db)
#' y
#' count(y, pmid, databank, sort=TRUE)
#' @export

pubmed_databanks <- function(nodes) {
  z <- lapply(nodes, xml2::xml_find_all, ".//DataBank")
  
  # Get all databanks
  x <- lapply(z, function(x) tibble::enframe(xml2::xml_text(xml2::xml_find_first(x, ".//DataBankName")), "n_databank", "databank"))
  x <- bind_rows(x, .id="pmid")
  
  # Get all accession numbers for each databank
  y <- lapply(z, xml_tidy_text, ".//AccessionNumber", "accession_number", 
              counter = "n_accession_number", id = "n_databank")
  y <- bind_rows(y, .id="pmid")
  
  # Join databanks and accession numbers
  x <- full_join(x, y, by = c("pmid", "n_databank"))
  
  x$pmid <- as.integer(x$pmid)
  
  x
}
