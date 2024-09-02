
<!-- force push by editing this number: 47 -->
<!-- README.md is generated from README.Rmd. Please edit that file -->

# roz <img src="man/figures/logo.png" align="right" height="137" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/fwimp/roz/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/fwimp/roz/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`roz` allows for R access to a variety of services provided by the
[onezoom](https://www.onezoom.org) project.

## Installation

You can install the development version of roz like so:

``` r
# install.packages("devtools")
devtools::install_github("fwimp/roz", build_vignettes = TRUE)
```

## Latest patch notes

<!-- These are auto-pulled from NEWS.md  -->

### roz 0.0.3

- Add `tools/exercise_roz_api.R` for testing the interface between `roz`
  and the OZ API.
- Remove return value from `oz_basereq()`.
- Force ott ids to be returned by `node_images()` as integers.
- Mitigate issue with header values from the OneZoom popularity
  endpoint. See [Issue
  \#875](https://github.com/OneZoom/OZtree/issues/875) for details.
