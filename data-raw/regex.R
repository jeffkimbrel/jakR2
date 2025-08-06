# regex for EC numbers, requires 4 numbers separated by a dot, or one number and up to 3 dashes.
EC_number_regex = "\\d+\\.[\\d\\-]+\\.[\\d\\-]+\\.[\\d-]+"
usethis::use_data(EC_number_regex, overwrite = TRUE)

# gene symbols are three lower case letters, followed by one or more upper case letters, and 0 or more numbers (like virB4)
gene_symbol_regex = "[a-z]{3}[A-Z]+[\\d]*"
usethis::use_data(gene_symbol_regex, overwrite = TRUE)
