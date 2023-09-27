# R Packages

This repository contains files that follow the book [R Packages (2e)](https://r-pkgs.org/) by [Hadley Wickham](https://hadley.nz/) and [Jennifer Bryan](https://jennybryan.org/).

The book introduces the [devtools](https://devtools.r-lib.org/) package, a meta-package that supports interactive package development.

Since its [conscious uncoupling], the devtools package was split into several smaller packages that are more tightly focused on specific tasks. These include:

- [testthat](https://testthat.r-lib.org/): Writing and running tests

- [roxygen2](https://roxygen2.r-lib.org/): Function and package documentation.

- [remotes](https://remotes.r-lib.org/): Installing packages.

- [pkgbuild](https://pkgbuild.r-lib.org/): Building binary packages.

- [pkgload](https://pkgload.r-lib.org/): Simulating package loading.

- [rcmdcheck](https://rcmdcheck.r-lib.org/): Running `R CMD check` and reporting results.

- [revdepcheck](https://revdepcheck.r-lib.org/): Running `R CMD check` on all reverse dependencies.

- [sessioninfo](https://sessioninfo.r-lib.org/): R session info.

- [usethis](https://usethis.r-lib.org/): Automating package setup.


Other packages referenced in the book include:

- [pak](https://pak.r-lib.org/): A fresh approach to R package installation.

- [renv](https://rstudio.github.io/renv/): Create **r**eproducible **env**ironments for your R projects.

- [covr](https://covr.r-lib.org/): Track test coverage for your R package.

- [hardhat](https://hardhat.tidymodels.org/): Ease the creation of new modeling packages following the [Conventions for R Modeling Packages](https://tidymodels.github.io/model-implementation-principles/).

- [cli](https://cli.r-lib.org/): Helpers for developing Command Line Interfaces (CLIs).

- [lifecycle](https://lifecycle.r-lib.org/): Tools and conventions to manage the life cycle of your exported functions.

- [waldo](https://waldo.r-lib.org/): Concisely describe the difference between a pair of R objects.

- [withr](https://withr.r-lib.org/): A set of functions to run code with safely and temporarily modified global state.

- [desc](https://desc.r-lib.org/): Parse, manipulate and reformat `DESCRIPTION` files.

- [cpp11](https://cpp11.r-lib.org/): Interact with R objects using C++ code.

- [fs](https://fs.r-lib.org/): A cross-platform, uniform interface to file system operations.

- [conflicted](https://conflicted.r-lib.org/): Provides an alternative conflict resolution strategy.

- [here](https://here.r-lib.org/): Enable easy file referencing in project-oriented workflows.


Sometimes you want to depend only on the underlying packages that many [tidyverse](https://www.tidyverse.org/) packages use under the hood:

- [vroom](https://vroom.r-lib.org/): The fastest delimited reader for R.

- [httr2](https://httr2.r-lib.org/): Provides a pipe-able API with an explicit request object that solves many problems felt by packages that wrap APIs.

- [vctrs](https://vctrs.r-lib.org/): Provides a new `vctr`class that includes features meant to help during package development.

- [tidyselect](https://tidyselect.r-lib.org/): The backend to several tidyverse verbs.


