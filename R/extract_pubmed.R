#' Extract dataypes from PubMed XML records
#'
#' @param filepath Character. Filepath including directory portion. Filepath should end in ".xml". If \code{pmid} is not provided, filename should be PMID.
#' @param pmid Character. Default = NULL in which case \code{pmid} parsed from the filename.
#' @param datatype Type of data to extract from xml for which there is a corresponding "pubmed_" function ("main", "abstract", "databanks", "authors", "mesh", "keywords", "pubtypes"). "main" used `pubmed_table()`
#' @param processed_dir Character. Default = NULL. Filepath of a directory to which processed file should be moved. By default, file will not be moved.
#' @param quiet Logical. Default = FALSE. Whether to inform user.
#'
#' @return Dataframe with output from corresponding "pubmed_" function
#'
#' @export

extract_pubmed <- function(filepath,
                           datatype = NULL,
                           pmid = NULL,
                           processed_dir = NULL,
                           quiet = FALSE){
  
  
  # Check for correct filetype
  if (fs::path_ext(filepath) != "xml"){
    rlang::abort("`filepath` must end in '.xml'")
  }
  
  datatypes <- c("main", "abstract", "databanks", "authors", "mesh", "keywords", "pubtypes")
  
  datatypes_txt <-
    glue::glue_collapse(glue::glue("'{datatypes}'"), sep = ", ", last = ", or ")
  
  # Check for valid datatype
  if (!datatype %in% datatypes){
    rlang::abort(glue::glue("`datatype` must be in {datatypes_txt}"))
  }
  
  # Convert "main" to table" (use "main" for user since clearer than "table")
  function_datatype <- ifelse(datatype == "main", "table", datatype)
  
  # Extract id from filepath if not user-provided
  if (purrr::is_null(pmid)){
    pmid <-
      filepath %>%
      fs::path_file() %>%
      fs::path_ext_remove()
  }
  pmid = as.numeric(pmid)
  
  article <-
    filepath %>%
    xml2::read_xml() %>%
    xml2::xml_find_all("PubmedArticle")
  
  # Move file if user specified
  if (!rlang::is_null(processed_dir)) {
    fs::dir_create(processed_dir)
    fs::file_move(filepath, processed_dir)
  }
  
  
  out <-
    rlang::exec(paste0("pubmed_", function_datatype), article) %>% #TODO: doesn't recognize function within other package
    dplyr::mutate(pmid = !!pmid) #%>%
  # dplyr::mutate(pmid = as.numeric(pmid))
  
  if (!quiet) {rlang::inform(glue::glue("{pmid}: extracted {datatype}"))}
  
  out
  
}
