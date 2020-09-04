#' Extract xml text in tidy format
#'
#' @param nodes article node set with PMID names
#' @param xpath xpath expression
#' @param attr xml attribute name
#' @param label column name, default is last part of xpath
#' @param counter name for counter column, default is `n`
#' @param id name for id column, default is `pmid`
#'
#' @return A tibble
#'
#' @examples
#' aq <- pubmed_nodeset(aqc)
#' xml_tidy_text(aq, "//Author/LastName")
#' xml_tidy_text(aq, "//Chemical/NameOfSubstance", "chemical")
#' xml_tidy_text(aq, "//Reference//ArticleId[@IdType='pubmed']", "cited")
#' @export

xml_tidy_text <- function(nodes, xpath, label, counter = "n", id = "pmid"){
  # use leading .
  if(!grepl("^\\.", xpath)) xpath <- paste0(".", xpath)
  if(missing(label)) label <- gsub(".*/", "", xpath)
  x <- lapply(nodes, function(x) xml2::xml_text(xml2::xml_find_all(x, xpath), trim = TRUE))
  x <- bind_rows(lapply(x, tibble::enframe, name = counter, label), .id=id)
  x[[id]] <- as.integer(x[[id]])
  x
}

#' @describeIn xml_tidy_text Extract xml attribute in tidy format
#' @export
xml_tidy_attr <- function(nodes, xpath, attr, label){
  if(!grepl("^\\.", xpath)) xpath <- paste0(".", xpath)
  if(missing(label)) label <- attr
  x <- lapply(nodes, function(x) xml2::xml_attr(xml2::xml_find_all(x, xpath), attr))
  x <- bind_rows(lapply(x, tibble::enframe, "n", label), .id="pmid")
  x$pmid <- as.integer(x$pmid)
  x
}
