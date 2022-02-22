#' Download PubMed record
#'
#' This is a wrapper around `rentrez::entrez_fetch()` that allows to `purrr::safely()` fetch and save a PubMed record.
#'
#' This function is *not* vectorized so wrap in `purrr::walk()` to run on multiple pmids.
#'
#' @param pmid 	character, publication identifier. PMID or PMCID.
#' @param dir character, director in which to save XMLs. Defaults to working directory with `here::here()`.
#' @param overwrite logical, if file exists, should it be overwritten? Defaults to `FALSE`.
#' @param api_key character. See `rentrez` documentation on [Rate-limiting and API Keys](https://cran.r-project.org/web/packages/rentrez/vignettes/rentrez_tutorial.html#rate-limiting-and-api-keys) for info on \code{api_key}. Defaults to NULL.
#' @param sleep delay in seconds. Defaults to NULL. If \code{api_key} provided, \code{sleep} set to 1/10 seconds, else to 1/3 seconds per [Entrez API limits](https://ncbiinsights.ncbi.nlm.nih.gov/2017/11/02/new-api-keys-for-the-e-utilities/).
#' @return If \code{pmid} successfully downloaded, returns XML. If \code{pmid} did not resolve, or already downloaded in \code{dir} (and \code{overwrite} is FALSE), returns NULL.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' download_pubmed(99999999,
#' dir = here("data", "raw", "pubmed"),
#' api_key = keyring::key_get("ncbi-pubmed")
#' )
#' }
#' \dontrun{
#' c(99999999, 12345678) %>%
#'   walk(download_pubmed,
#'        dir = here("data", "raw", "pubmed"),
#'        api_key = keyring::key_get("ncbi-pubmed")
#'   )
#' }

download_pubmed <- function(pmid,
                            dir = here::here(),
                            overwrite = FALSE,
                            api_key = NULL,
                            sleep = NULL){
  
  # Check input
  if (!stringr::str_detect(pmid, "[0-9]{8}")) {
    rlang::abort(glue::glue("{pmid} is not a valid pmid"))
  }
  
  # Create directory, if it doesn't exist
  fs::dir_create(dir)
  
  # Construct filepath
  filepath <- fs::path(dir, pmid, ext = "xml")
  
  # If file exists and not overwriting, don't download, and return NULL
  if (!overwrite && fs::file_exists(filepath)){
    rlang::inform(glue::glue("{pmid}: Already downloaded"))
    return(NULL)
  }
  
  # Set sleep time, then sleep
  if (rlang::is_null(sleep)){
    if (!rlang::is_null(api_key)) {
      sleep <- 1/10
    } else {sleep <- 1/3}
  }
  
  Sys.sleep(jitter(sleep))
  
  # Capture errors when fetching full-text
  safely_entrez_fetch <- purrr::safely(rentrez::entrez_fetch)
  
  # Fetch full text from Europe PMC
  resp <- safely_entrez_fetch(db = "pubmed", id = pmid, rettype = "xml", parsed = FALSE, api_key = api_key)
  
  # resp <- rentrez::entrez_fetch(db = "pubmed", id = pmid, rettype = "xml", parsed = FALSE, api_key = api_key)
  
  # If xml downloaded error, inform about error, and return NULL
  if (!rlang::is_null(resp$error)){
    rlang::inform(glue::glue("{pmid}: {resp$error$message}"))
    return(NULL)
  }
  
  # Otherwise xml successfully downloaded
  out <- resp$result
  
  # However, entrez may return xml without article, but no error, so parse to check for non-missing article
  xml_class <-
    out %>%
    xml2::read_xml() %>%
    xml2::xml_find_first("PubmedArticle") %>%
    class()
  if (xml_class == "xml_missing"){
    rlang::inform(glue::glue("{pmid}: Download missing 'PubmedArticle'"))
    return(NULL)
  } else {
    
    # If valid pubmed article, save xml
    readr::write_file(out, filepath)
    rlang::inform(glue::glue("{pmid}: Successful download"))
  }
  
  return(out)
  
}
