# data-cleaning_v7.R

devtools::install(pkg = "C:/Users/matth/OneDrive/Dokumente/R-pkgs/golf")
library(golf)
library(tidyverse)

infile <- "swim.csv"
dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

dat <- dat |>
  localize_beach() |>
  celsify_temp()

write_csv(dat, outfile_path(infile))
# END
