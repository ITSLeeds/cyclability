
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cyclability

<!-- badges: start -->
<!-- badges: end -->

The goal of cyclability is to generate estimates of broadly defined
cyclability. There are at least three definitions of how conducive to
cycling different places and segments of roads and travel networks are:

- Level of Traffic Stress (LTS)
- [Bikeability](https://www.britishcycling.org.uk/cycletraining/article/ct20110111-cycletraining-What-is-Bikeability-0)
  levels, which rates infrastructure based on the level of training
  needed to feel comfortable:
  - Level 1 teaches basic bike-handling skills in a controlled
    traffic-free environment.
  - Level 2 teaches trainees to cycle planned routes on minor roads,
    offering a real cycling experience.
  - Level 3 ensures trainees are able to manage a variety of traffic
    conditions and is delivered on busier roads with advanced features
    and layouts
- CycleStreets’s [Quietness
  rating](https://www.cyclestreets.net/help/journey/howitworks/#quietness)
  from 1 (very unpleasant for cycling) to 100 (the quietest)

# Setup

For this practical we’ll be using a number of R packages, which can be
installed as follows:

``` r
# core packages:
install.packages("remotes")
core_packages = c(
  "tidyverse",
  "sf",
  "tmap"
)
remotes::install_cran(core_packages)
```

Other packages that we use which you may want to install include:

``` r
other_packages = c(
  "r5r",
  "cyclestreets"
)
remotes::install_cran(other_packages)
#> Skipping install of 'r5r' from a cran remote, the SHA1 (0.7.1) has not changed since last install.
#>   Use `force = TRUE` to force installation
#> Skipping install of 'cyclestreets' from a cran remote, the SHA1 (0.5.3) has not changed since last install.
#>   Use `force = TRUE` to force installation
```

For the practical we assume you have the following packages loaded:

``` r
library(tidyverse)
```

# Cyclability data

## LTS data from R5

To get estimates of LTS on the network we used the R5 routing engine via
the `r5r` package. See [code/r5r_setup.R](code/r5r_setup.R) for details.

The resulting estimates of LTS in Leeds can be read-in and visualised as
follows:

``` r
""
#> [1] ""
```

## Quitness data from CycleStreets

# OSM data

# Estimating cyclability with OSM

The purpose of the hackathon!
