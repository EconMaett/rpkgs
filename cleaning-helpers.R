# cleaning-helpers.R

library(tidyverse)

localize_beach <- function(dat) {
  lookup_table <- read_csv(
    file = "beach-lookup-table.csv",
    col_types = cols(where = "c", english = "c")
  )
  left_join(x = dat, y = lookup_table, by = join_by(where))
}

f_to_c <- function(x) (x - 32) * 5 / 9

celsify_temp <- function(dat) {
  mutate(.data = dat, temp = if_else(condition = english == "US", true = f_to_c(temp), false = temp))
}

now <- Sys.time()
timestamp <- function(time) format(time, "%Y-%B-%d_%H-%M-%S")
outfile_path <- function(infile) {
  paste0(timestamp(now), "_", sub(pattern = "(.*)([.]csv$)", replacement = "\\1_clean\\2", x = infile))
}

# END
