# data-cleaning_v2.R
library(tidyverse)

infile <- "swim.csv"
dat <- read_csv(file = infile, col_types = cols(name = "c", where = "c", temp = "d"))

lookup_table <- tribble(
  ~ where, ~ english,
  "beach", "US",
  "coast", "US",
  "seashore", "UK",
  "seaside", "UK"
)

dat <- dat |> 
  left_join(y = lookup_table, by = join_by(where))

f_to_c <- function(x) (x - 32) * 5 / 9

dat <- dat |> 
  mutate(temp = if_else(condition = english == "US", true = f_to_c(temp), false = temp))


now <- Sys.time()
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub(pattern = "(.*)([.]csv$)", replacement = "\\1_clean\\2", x = infile))
}

write_csv(dat, file = outfile_path(infile))
# END