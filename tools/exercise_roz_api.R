#!/usr/bin/env Rscript

# Date: 02/09/24
# Author: Francis Windram

# Provide a simple testing system for the roz package for use by API developers

# Check for argparse & purrr
rlang::check_installed("argparse")
rlang::check_installed("purrr")


# Create argparser
parser <- argparse::ArgumentParser(description = "Test roz package API interactions.")

# Add options
parser$add_argument("url", default = "https://www.onezoom.org/", help = "The base level URL of OneZoom.")
parser$add_argument("-c", "--compat", action = "store_true", help = "Use compatability mode for http queries.")
parser$add_argument("-l", "--local", action = "store_true", help = "Load local package from source using devtools.")
parser$add_argument("-m", "--nosuppressmessages", action = "store_false", default = TRUE, help = "Disable suppression of package messages.")

args <- parser$parse_args()

# Finished parsing args

suppressWarnings(library(cli))
cli_h1("roz API Tester")
cli_h2("Arguments")
cli_alert_info("Testing against {.url {args$url}}")
if (args$compat) {
  cli_alert_success("Compatability mode")
}

if (args$local) {
  cli_alert_success("Local loading mode")
}

suppress <- args$nosuppressmessages

if (args$nosuppressmessages) {
  cli_alert_success("Suppressing package messages")
} else {
  cli_alert_success("Not suppressing package messages")
}

cli_progress_message("{cli::symbol$pointer} Loading {.pkg roz}...")
Sys.sleep(1)

if (args$local) {
  cli_progress_message("{cli::symbol$pointer} Loading {.pkg roz} from local source...")
  devtools::load_all("../")
} else {
  tryCatch({
    cli_progress_message("{cli::symbol$pointer} Loading installed {.pkg roz}...")
    library(roz)
  }, error = function(cond) {
    cli_progress_done()
    if (rlang::is_installed("withr")) {
      withr::with_options(list(rlang_backtrace_on_error = "none"), {
        cli_abort(c("x" = "{.pkg roz} not installed. Try loading using the {.arg -l} argument."))
      })
    } else {
      cli_abort(c("x" = "{.pkg roz} not installed. Try loading using the {.arg -l} argument."))
    }
  })
}

cli_h2("Setting up")
if (args$compat) {
  set_oz_compat()
}

basereq <- oz_basereq(args$url)
cli_alert_success("Set up base request using {.url {args$url}}")

supressFlexi <- function(x, suppress = TRUE) {
  if (suppress) {
    return(suppressMessages(x))
  } else {
    return(x)
  }
}

cli_h1("Testing suite")

cli_text("Testing the following functions:")
cli_ul()
cli_li(col_yellow("{.fn roz::identifier2ott}"))
cli_li(col_yellow("{.fn roz::node_images}"))
cli_li(col_yellow("{.fn roz::ott2common}"))
cli_li(col_yellow("{.fn roz::ott2identifiers}"))
cli_li(col_yellow("{.fn roz::popularity}"))

# Actually test

## identifier2ott
cli_h2("identifier2ott {.emph (endpoint: getOTT)}")
cli_progress_message("{cli::symbol$pointer} Testing identifier2ott...")
identifier2ott_fail <- FALSE
otts <- tryCatch({
  otts <- supressFlexi(identifier2ott(eol = c(1228387, 7674), gbif = c(1651891), ncbi = c(389061), iucn = (9194), basereq = basereq), suppress)
  cli_alert_success("Executed successfully")
  otts
}, error = function(cond) {
  identifier2ott_fail <- TRUE
  NULL
  # print(cond)
})

if (identifier2ott_fail) {
  # Check success
  cli_alert_danger("Failed to execute")
  cli_alert_danger("Skipping check")

} else {
  cli_progress_message("{cli::symbol$pointer} Checking identifier2ott...")
  # Check num fields
  if (length(otts) == 5) {
    cli_alert_success("Correct number of fields in response")
  } else {
    cli_alert_danger("Incorrect number of fields in response (got {.val {length(otts)}}, expected {.val {5}})")
    identifier2ott_fail <- TRUE
  }

  otts_flat <- purrr::list_c(otts)
  cli_alert_success("{.val {length(otts_flat)}} ott id{?s} returned")

  all_numeric <- TRUE

  for (i in seq_along(otts_flat)) {
    if (!is.numeric(otts_flat[[i]])) {
      all_numeric <- FALSE
    }
  }

  # Check ids are numeric
  if (all_numeric) {
    cli_alert_success("All ids are numeric!")
  } else {
    cli_alert_danger("Not all ids are numeric")
    cli_progress_done()
    cli_h3("Response contents")
    cat("\n")
    print(otts)
    identifier2ott_fail <- TRUE
  }

}

if (identifier2ott_fail) {
  cli_alert_danger("{col_red('identifier2ott FAIL')}")
} else {
  cli_alert_success("{col_green('identifier2ott SUCCESS')}")
}

## node_images

cli_h2("node_images {.emph (endpoint: node_images)}")
cli_progress_message("{cli::symbol$pointer} Testing node_images...")
node_images_fail <- FALSE
images <- tryCatch({
  images <- supressFlexi(node_images(c(247341, 269666, 504327, 668392), basereq = basereq), suppress)
  cli_alert_success("Executed successfully")
  images
}, error = function(cond) {
  node_images_fail <- TRUE
  NULL
})

if (node_images_fail) {
  # Check success
  cli_alert_danger("Failed to execute")
  cli_alert_danger("Skipping check")

} else {
  cli_progress_message("{cli::symbol$pointer} Checking node_images...")

  # Check number of rows
  if (nrow(images) == 4) {
    cli_alert_success("Correct number of rows in response")
  } else {
    cli_alert_danger("Incorrect number of rows in response (got {.val {nrow(images)}}, expected {.val {4}})")
    node_images_fail <- TRUE
  }

  cli_alert_success("{.val {nrow(images)}} image{?s} returned")

  # Check number of columns
  if (ncol(images) == 6) {
    cli_alert_success("Correct number of fields in response")
  } else {
    cli_alert_danger("Incorrect number of fields in response (got {.val {ncol(images)}}, expected {.val {6}})")
    node_images_fail <- TRUE
  }

  # Check column types
  coltypes <- c("numeric", "character", "character", "character", "character", "integer")
  # coltypes <- c("numeric", "character", "character", "character", "character", "character")
  if (all(as.character(sapply(images, class)) == coltypes)) {
    cli_alert_success("Correct types of fields in response")
  } else {
    cli_alert_danger("Incorrect types of fields in response!")
    column_names <- colnames(images)
    column_types <- as.character(sapply(images, class))
    selecta <- as.character(sapply(images, class)) == coltypes
    selecta <- !selecta
    errdf <- data.frame(colname = column_names[selecta], expected = coltypes[selecta], got = column_types[selecta])
    cli_progress_done()
    cli_h3("Errored column types:")
    cat("\n")
    print(errdf)
    cat("\n")
    node_images_fail <- TRUE
  }
}

if (node_images_fail) {
  cli_alert_danger("{col_red('node_images FAIL')}")
} else {
  cli_alert_success("{col_green('node_images SUCCESS')}")
}

## ott2common
cli_h2("ott2common {.emph (endpoint: otts2vns)}")
cli_progress_message("{cli::symbol$pointer} Testing ott2common...")
ott2common_fail <- FALSE
commons <- tryCatch({
  commons <- supressFlexi(ott2common(c(247341, 563159, 269666, 504327, 668392), basereq = basereq), suppress)
  cli_alert_success("Executed successfully")
  commons
}, error = function(cond) {
  ott2common_fail <- TRUE
  NULL
})

if (ott2common_fail) {
  # Check success
  cli_alert_danger("Failed to execute")
  cli_alert_danger("Skipping check")

} else {
  cli_progress_message("{cli::symbol$pointer} Checking ott2common...")

  # Check number of rows
  if (nrow(commons) == 5) {
    cli_alert_success("Correct number of rows in response")
  } else {
    cli_alert_danger("Incorrect number of rows in response (got {.val {nrow(commons)}}, expected {.val {5}})")
    ott2common_fail <- TRUE
  }

  cli_alert_success("{.val {nrow(commons)}} common name{?s} returned")

  # Check number of fields
  if (ncol(commons) == 2) {
    cli_alert_success("Correct number of fields in response")
  } else {
    cli_alert_danger("Incorrect number of fields in response (got {.val {ncol(commons)}}, expected {.val {2}})")
    ott2common_fail <- TRUE
  }

  # Check field types
  coltypes <- c("numeric", "character")
  # coltypes <- c("character", "character")
  if (all(as.character(sapply(commons, class)) == coltypes)) {
    cli_alert_success("Correct types of fields in response")
  } else {
    cli_alert_danger("Incorrect types of fields in response!")
    column_names <- colnames(commons)
    column_types <- as.character(sapply(commons, class))
    selecta <- as.character(sapply(commons, class)) == coltypes
    selecta <- !selecta
    errdf <- data.frame(colname = column_names[selecta], expected = coltypes[selecta], got = column_types[selecta])
    cli_progress_done()
    cli_h3("Errored column types:")
    cat("\n")
    print(errdf)
    cat("\n")
    ott2common_fail <- TRUE
  }
}

commons_all <- tryCatch({
  commons_all <- supressFlexi(ott2common(c(247341, 563159, 269666, 504327, 668392), basereq = basereq, findall = TRUE), suppress)
  commons_all
}, error = function(cond) {
  ott2common_fail <- TRUE
  NULL
})

# Check success
if (!is.null(commons_all)) {
  cli_alert_success("Findall variant successful")

  # Check number of rows in findall is the same
  if (nrow(commons_all) == nrow(commons)) {
    cli_alert_success("Correct number of rows in findall response")
  } else {
    cli_alert_danger("Incorrect number of rows in  findall response (got {.val {nrow(commons_all)}}, expected {.val {nrow(commons)}})")
    ott2common_fail <- TRUE
  }

  # Check that findall finds more than single search
  if (ncol(commons_all) > ncol(commons)) {
    cli_alert_success("Findall found more names than single search.")
  } else {
    cli_alert_danger("Findall did not find more than single search! findall = {.val {ncol(commons_all)}}, single = {.val {ncol(commons)}}")
    ott2common_fail <- TRUE
  }
} else {
  cli_alert_danger("Findall variant failed")
}

if (ott2common_fail) {
  cli_alert_danger("{col_red('ott2common FAIL')}")
} else {
  cli_alert_success("{col_green('ott2common SUCCESS')}")
}

## ott2identifiers

cli_h2("ott2identifiers {.emph (endpoint: otts2identifiers)}")
cli_progress_message("{cli::symbol$pointer} Testing ott2identifiers...")
ott2identifiers_fail <- FALSE
identifiers <- tryCatch({
  identifiers <- supressFlexi(ott2identifiers(c(247341, 563159, 269666, 504327, 668392), basereq = basereq), suppress)
  cli_alert_success("Executed successfully")
  identifiers
}, error = function(cond) {
  ott2identifiers_fail <- TRUE
  NULL
})

if (ott2identifiers_fail) {
  # Check success
  cli_alert_danger("Failed to execute")
  cli_alert_danger("Skipping check")

} else {
  cli_progress_message("{cli::symbol$pointer} Checking ott2identifiers...")
  # Check num rows
  if (nrow(identifiers) == 5) {
    cli_alert_success("Correct number of rows in response")
  } else {
    cli_alert_danger("Incorrect number of rows in response (got {.val {nrow(identifiers)}}, expected {.val {5}})")
    ott2identifiers_fail <- TRUE
  }

  cli_alert_success("{.val {nrow(commons)}} identifier{?s} returned")

  # Check number of fields
  if (ncol(identifiers) == 10) {
    cli_alert_success("Correct number of fields in response")
  } else {
    cli_alert_danger("Incorrect number of fields in response (got {.val {ncol(identifiers)}}, expected {.val {10}})")
    ott2identifiers_fail <- TRUE
  }

  # Check field types are integer or logical
  coltypes <- rep("integer", ncol(identifiers))
  coltypes_2 <- rep("logical", ncol(identifiers))
  column_types <- as.character(sapply(identifiers, class))
  selecta <- column_types == coltypes | column_types == coltypes_2

  if (all(selecta)) {
    cli_alert_success("Correct types of fields in response")
  } else {
    cli_alert_danger("Incorrect types of fields in response!")
    column_names <- colnames(identifiers)
    selecta <- !selecta
    errdf <- data.frame(colname = column_names[selecta], expected = rep("integer/logical", length(column_names[selecta])), got = column_types[selecta])
    cli_progress_done()
    cli_h3("Errored column types:")
    cat("\n")
    print(errdf)
    cat("\n")
    ott2identifiers_fail <- TRUE
  }

}

if (ott2identifiers_fail) {
  cli_alert_danger("{col_red('identifier2ott FAIL')}")
} else {
  cli_alert_success("{col_green('identifier2ott SUCCESS')}")
}

## popularity
cli_h2("popularity {.emph (endpoint: popularity/list)}")
cli_progress_message("{cli::symbol$pointer} Testing popularity...")
popularity_fail <- FALSE
popularity_out <- tryCatch({
  popularity_out <- supressFlexi(popularity(c(247341, 563159, 269666, 504327, 668392), basereq = basereq), suppress)
  cli_alert_success("Executed successfully")
  popularity_out
}, error = function(cond) {
  popularity_fail <- TRUE
  NULL
})

if (popularity_fail) {
  # Check success
  cli_alert_danger("Failed to execute")
  cli_alert_danger("Skipping check")
} else {
  cli_progress_message("{cli::symbol$pointer} Checking popularity...")
  # Check num rows
  if (nrow(popularity_out) == 5) {
    cli_alert_success("Correct number of rows in response")
  } else {
    cli_alert_danger("Incorrect number of rows in response (got {.val {nrow(popularity_out)}}, expected {.val {5}})")
    popularity_fail <- TRUE
  }

  cli_alert_success("{.val {nrow(popularity_out)}} popularity value{?s} returned")

  # Check number of fields
  if (ncol(popularity_out) == 3) {
    cli_alert_success("Correct number of fields in response")
  } else {
    cli_alert_danger("Incorrect number of fields in response (got {.val {ncol(popularity_out)}}, expected {.val {3}})")
    popularity_fail <- TRUE
  }

  # Check column types
  coltypes <- c("integer", "numeric", "integer")
  # coltypes <- c("integer", "numeric", "character")

  if (all(as.character(sapply(popularity_out, class)) == coltypes)) {
    cli_alert_success("Correct types of fields in response")
  } else {
    cli_alert_danger("Incorrect types of fields in response!")
    column_names <- colnames(popularity_out)
    column_types <- as.character(sapply(popularity_out, class))
    selecta <- as.character(sapply(popularity_out, class)) == coltypes
    selecta <- !selecta
    errdf <- data.frame(colname = column_names[selecta], expected = coltypes[selecta], got = column_types[selecta])
    cli_progress_done()
    cli_h3("Errored column types:")
    cat("\n")
    print(errdf)
    cat("\n")
    popularity_fail <- TRUE
  }

}

# Test if expand gives more results
popularity_out_expand <- tryCatch({
  popularity_out_expand <- supressFlexi(popularity(c(247341, 563159, 269666, 504327, 668392), maxtaxa = 50, expand = TRUE, basereq = basereq), suppress)
  popularity_out_expand
}, error = function(cond) {
  popularity_fail <- TRUE
  NULL
})

if (!is.null(popularity_out_expand)) {
  cli_alert_success("Expand variant successful")

  # Check expand adds more entries
  if (nrow(popularity_out_expand) > nrow(popularity_out)) {
    cli_alert_success("Expand found more names than non-expanded search")
  } else {
    cli_alert_danger("Expand did not find more than non-expanded search! expand = {.val {nrow(popularity_out_expand)}}, non-expand = {.val {nrow(popularity_out)}}")
    popularity_fail <- TRUE
  }

} else {
  cli_alert_danger("Expand variant failed")
  popularity_fail <- TRUE
}

popularity_out_clamped <- tryCatch({
  popularity_out_clamped <- supressFlexi(popularity(c(247341, 563159, 269666, 504327, 668392), maxtaxa = 3, expand = TRUE, basereq = basereq), suppress)
  popularity_out_clamped
}, error = function(cond) {
  popularity_fail <- TRUE
  NULL
})

if (!is.null(popularity_out_clamped)) {
  cli_alert_success("Clamped variant successful")

  # Check expand adds more entries
  if (nrow(popularity_out_expand) > nrow(popularity_out_clamped)) {
    cli_alert_success("Maxtaxa reduced number of responses")
  } else {
    cli_alert_danger("Maxtaxa did not reduce number of responses! expand (50) = {.val {nrow(popularity_out_expand)}}, maxtaxa (4) = {.val {nrow(popularity_out_clamped)}}")
    popularity_fail <- TRUE
  }

} else {
  cli_alert_danger("Maxtaxa variant failed")
  popularity_fail <- TRUE
}

popularity_out_raw <- tryCatch({
  popularity_out_raw <- supressFlexi(popularity(c(247341, 563159, 269666, 504327, 668392), include_raw = TRUE, basereq = basereq), suppress)
  popularity_out_raw
}, error = function(cond) {
  popularity_fail <- TRUE
  NULL
})

if (!is.null(popularity_out_raw)) {
  cli_alert_success("Raw variant successful")

  if (ncol(popularity_out_raw) == ncol(popularity_out) + 1) {
    cli_alert_success("Raw added exactly one column")
  } else {
    cli_alert_danger("Raw did not add exactly one column! original = {.val {ncol(popularity_out)}}, include_raw = {.val {ncol(popularity_out_raw)}}")
    popularity_fail <- TRUE
  }

} else {
  cli_alert_danger("Raw variant failed")
  popularity_fail <- TRUE
}

if (popularity_fail) {
  cli_alert_danger("{col_red('popularity FAIL')}")
} else {
  cli_alert_success("{col_green('popularity SUCCESS')}")
}

cli_h1("Results")

fail_flags <- c(identifier2ott_fail, node_images_fail, ott2common_fail, ott2identifiers_fail, popularity_fail)

fails <- sum(fail_flags)
successes <- length(fail_flags) - fails

failstr <- col_red("{fails} FAIL{?S}")
successstr <- col_green("{successes} SUCCESS{?ES}")
cli_text(failstr)
cli_text(successstr)
cli_progress_done()
cli_h1("Testing complete!")
