
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

### roz 0.0.2

- Add `node_images()` to allow for retrieval of public domain and cc
  images.
- Add experimental `identifier2ott()` function to allow for mapping
  between other ids and ott.
