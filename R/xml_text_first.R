#' Extract first xml text
#'
#' @param nodes article node set with PMID names
#' @param xpath xml node name
#' @param attr xml attribute name
#'
#' @return A vector. Used by \code{pubmed_table} to add additional columns
#'
#' @examples
#' aq <- pubmed_nodeset(aqc)
#' xml_text_first(aq, "//Author/LastName")
#' @export

xml_text_first <- function(nodes, xpath){
   if(!grepl("^\\.", xpath)) xpath <- paste0(".", xpath)
   y <- sapply(nodes, function(x) xml2::xml_text(xml2::xml_find_first(x, xpath), trim=TRUE))
   y <- unlist(y)
   unname(y)
}

#' @describeIn xml_text_first Extract first xml attribute as vector
#' @export
xml_attr_first <- function(nodes, xpath, attr){
   if(!grepl("^\\.", xpath)) xpath <- paste0(".", xpath)
   y <- sapply(nodes, function(x) xml2::xml_attr(xml2::xml_find_first(x, xpath), attr))
   y <- unlist(y)
   unname(y)
}
