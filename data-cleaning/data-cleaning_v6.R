# data-cleaning_v6.R
library(tidyverse)

orig_wd <- getwd()

infile <- "swim.csv"

dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat

delta_dir <- "C:/Users/matth/OneDrive/Dokumente/R-pkgs/delta"
setwd(dir = delta_dir)
devtools::install()
library(delta)

dat <- dat |>
  delta::localize_beach() |>
  delta::celsify_temp()

write_csv(dat, paste0(orig_wd, "/", delta::outfile_path(infile)))

setwd(dir = orig_wd)
# END
