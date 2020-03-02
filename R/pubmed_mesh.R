#' Parse MeSH terms
#'
#' @param nodes article node set
#'
#' @return A tibble
#'
#' @examples
#' aq <- pubmed_nodeset(aqc)
#' x <- pubmed_mesh(aq)
#' x
#' mutate(x, mesh=gsub("\\*", "", mesh)) %>%
#'   count(mesh, sort=TRUE)
#' unique(x[, 1:3]) %>%
#'   count(descriptor, sort=TRUE)
#' @export

pubmed_mesh <- function(nodes){
   # MeshHeading with 1 descriptor and 0 or more qualifiers
   z <- lapply(nodes, function(x) xml2::xml_find_all(x, ".//MeshHeading"))
   x <- lapply(z, function(x) tibble::enframe( xml2::xml_text(xml2::xml_find_first(x, ".//DescriptorName")), "n", "descriptor"))
   for(i in seq_along(x)){
     if(nrow(x[[i]]) > 0 ){
       # get qualifiers
       q1 <- lapply(z[[i]], function(x)  xml2::xml_text(xml2::xml_find_all(x, ".//QualifierName")))
	   q1[lengths(q1) == 0] <- NA
	   n <- lengths(q1)
	   ## repeat rows up to number of qualifiers
	   if(any(n > 1)) x[[i]] <- x[[i]][rep(rownames(x[[i]]), n ), ]
	   x[[i]]$qualifier <- unlist(q1)
       ## major topic
	   q1 <- lapply(z[[i]], function(x) xml2::xml_attr(xml2::xml_find_all(x, ".//QualifierName"), "MajorTopicYN" ))
       q2 <- sapply(z[[i]], function(x) xml2::xml_attr(xml2::xml_find_first(x, ".//DescriptorName"), "MajorTopicYN" ))
	   # only use descriptor majortopic if qualifier is missing
       n <- lengths(q1)
       q1[n == 0] <- q2[n == 0]
	   x[[i]]$majortopic <- unlist(q1)
     }
   }
   x <- bind_rows(x, .id="pmid")
   x$pmid <- as.integer(x$pmid)
   x <- mutate(x, mesh=ifelse( is.na(qualifier),
           paste0(descriptor, ifelse(majortopic == "Y", "*", "")),
           paste0(descriptor,"/", qualifier, ifelse(majortopic == "Y", "*", ""))))
   x
}
