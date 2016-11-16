#' @importFrom crayon %+%
#' @importFrom crayon green
#' @importFrom crayon blue
#' @importFrom crayon silver
#' @importFrom stringr str_dup
.onAttach <- function(libname, pkgname) {

  # http://www.asciiset.com/figletserver.html (chunky)

  banner <-
"
                            __  __         __      __     __           __
.-----..--.--.--..-----..--|  ||__|.-----.|  |--. |  |--.|__|.----..--|  |
|__ --||  |  |  ||  -__||  _  ||  ||__ --||     | |  _  ||  ||   _||  _  |
|_____||________||_____||_____||__||_____||__|__| |_____||__||__|  |_____|
                                               __
.----..-----..----..-----..--.--..-----..----.|__|.-----..-----.
|   _||  -__||  __||  _  ||  |  ||  -__||   _||  ||  -__||__ --|
|__|  |_____||____||_____| \`___/ |_____||__|  |__||_____||_____|
"

  `%+%` <- crayon::`%+%`
  r <- stringr::str_dup

  g <- crayon::green $ bgWhite
  b <- crayon::blue $ bgWhite
  s <- crayon::silver $ bgWhite

  PKG <- "swedishbirdrecoveries"

  styled_banner <-
    g("Welcome to ...") %+% s(r(" ", 11)) %+%
    s("https://") %+% b("mskyttner") %+% s(paste0(".github.io/", PKG))  %+%
    b(banner) %+%
    g(paste0("New to '", PKG, "'? For a tutorial, use:"))  %+%
    g(paste0("\nvignette('", PKG, "-vignette')")) %+%
    g(r(" ", 9)) %+%
    g(paste0("\n\nWant to silence this banner? ",
      "Instead of 'library(", PKG, ")', use:")) %+%
    g(paste0("\nsuppressPackageStartupMessages(library(", PKG, "))\n")) %+%
    g(r(" ", 9)) %+%
    g("\nTo try out the bundled shiny web application examples:") %+%
    g("\nrunShinyApp()\n") %+%
    g(r(" ", 4))

  suppressWarnings(packageStartupMessage(styled_banner))
}
