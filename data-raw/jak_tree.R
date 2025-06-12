## code to prepare `jak_tree` dataset goes here
load(here::here("data-raw", "jak_tree.rds"))
jak_tree = tree

usethis::use_data(jak_tree, overwrite = TRUE)
