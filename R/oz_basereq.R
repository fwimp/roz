#' @title Generate a base request object for the onezoom database
#' @description This request is used as the basis for all calls to the onezoom API.
#' It does not contain any tokens or session ids, and thus can be regenerated at any time.
#'
#' @param baseurl the base url for the onezoom API.
#' @param useragent the user agent string used when contacting onezoom.
#' @param unsafe disable ssl verification (should only ever be required on Linux, **do not enable this by default**).
#' @author Francis Windram
#' @return Returns an httr2 request object, pointing at baseurl using useragent
#'
#' @examples
#' \dontrun{
#' basereq <- oz_basereq(
#'   baseurl="https://www.onezoom.org/",
#'   useragent="ROZ")
#' }
#'
#' @concept basereq
#'
#' @export
#'


oz_basereq <- function(baseurl = "https://www.onezoom.org/", useragent = "ROZ", unsafe = FALSE) {

  if (getOption("oz_compat", default = FALSE) && isFALSE(unsafe)) {
    unsafe <- TRUE
  }

  req <- request(baseurl) %>% req_user_agent(useragent)
  if (unsafe) {
    req <- req %>% req_options(ssl_verifypeer = 0)
  }
  return(req)
}


#' @title Set roz compatability mode to TRUE
#' @description Set roz to disable ssl verification for calls to external APIs.
#' This should not be needed (and not be performed) unless you are running on a linux machine or are otherwise experiencing SSL issues when using the package!
#'
#' @param value The boolean value to set oz_compat to.
#' @author Francis Windram
#' @return NULL
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' set_oz_compat()
#' }

set_oz_compat <- function(value = TRUE) {

  if (!is_bool(value)) {
    cli_abort(c("x" = "{.arg value} must be a boolean (TRUE/FALSE)! Provided {.val {value}}"))
  }

  options(oz_compat = value)
  cli_alert_success("Set compatibility mode = {.val {getOption('oz_compat')}}")
  return(NULL)
}
