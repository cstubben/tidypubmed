#' Parse abstract
#'
#' @param nodes article node set
#' @param sentence split into sentences
#'
#' @return A tibble
#'
#' @examples
#' # can't save xml_nodesets in R/data
#' aq <- pubmed_nodeset(aqc)
#' x <- pubmed_abstract(aq)
#' x
#' mutate(x, text=ifelse(is.na(label), abstract, paste0(label, ": ", abstract))) %>%
#'   group_by(pmid) %>%
#'   summarize(abstract=paste(text, collapse=" ")) %>%
#'   arrange(desc(pmid))
#' pubmed_abstract(aq, sentence=TRUE)
#' @export

pubmed_abstract <- function(nodes, sentence=FALSE){
   z <- lapply(nodes, function(x) xml2::xml_find_all(x, ".//AbstractText"))
   x <- lapply(lapply(z, xml2::xml_text, trim=TRUE), tibble::enframe, "paragraph", "abstract")
   x <- bind_rows(x, .id="pmid")
   x$pmid <- as.integer(x$pmid)
   x$label <- unlist(lapply(z, xml2::xml_attr, "Label"))
   if(sentence){
      x1 <-lapply(x$abstract, tokenizers::tokenize_sentences)
      y <- lapply(x1, function(z) tibble::enframe(unlist(z), "sentence", "abstract"))
      y <- bind_rows(y)
      n <- sapply(x1, function(z) length(unlist(z)))
      z <- x[rep(1:nrow(x), n),-3]
      x <- bind_cols(z[,1:2], y, z[,3])
   }
   x
}
