#' Parse keywords
#'
#' @param nodes article node set
#'
#' @return A tibble
#'
#' @examples
#' aq <- pubmed_nodeset(aqc)
#' x <- pubmed_keywords(aq)
#' x
#' count(x, keyword, sort=TRUE)
#' @export

pubmed_keywords <- function(nodes){
   if(class(nodes)!= "xml_nodeset") stop("nodes should be an xml_nodeset from article_nodes")
   x1 <- xml_tidy_text(nodes, "//Keyword", "keyword")
   y1 <- xml_tidy_attr(nodes, "//Keyword", "MajorTopicYN", "majortopic")
   if(nrow(x1) != nrow(y1)) message("WARNING: missing some MajorTopic attribute nodes")
   k1 <- right_join(y1, x1, by=c("pmid", "n"))
   k1$pmid <- as.integer(k1$pmid)
   ## fix all CAPS if 5 or more
   n <- grep("^[A-Z ]{5,}$", k1$keyword)
   if(length(n)>0) k1$keyword[n] <- tolower(k1$keyword[n])
   k1
}
