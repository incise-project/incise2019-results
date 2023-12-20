### {gt} helpers
### functions to assist with table output

# read markdown table
read_md_tbl <- function(x) {

  x <- readLines(x)

  readr::read_delim(
    I(x[!grepl("^(:?)={2}", x)]),
    delim = "|",
    trim_ws = TRUE
  )

}

# function to convert character percentages into dbl vectors with formatting
convert_percent <- function(x, digits = 0, scale = 100) {
  formattable::percent(
    as.numeric(gsub("%", "", x))/scale,
    digits = digits
  )
}

# function to insert a RAG rating image
rag_image <- function(x) {

  x <- tolower(substr(x, 1, 1))

  alt <- dplyr::case_when(
    x == "g" ~ "Green",
    x == "a" ~ "Amber",
    x == "r" ~ "Red",
    TRUE ~ "x"
  )

  img <- dplyr::case_when(
    x == "g" ~ "figures/green-circle.png",
    x == "a" ~ "figures/amber-circle.png",
    x == "r" ~ "figures/red-circle.png",
    TRUE ~ "figures/grey-x.png"
  )

  paste0("<img src=\"", img, "\" alt=\"", alt,"\">")

}

# function to strip a gt::gt() for optimal processing
#   - convert to HTML object and force css class names
#   - remove containing div (local style defs), set as a table.table
strip_gt <- function(x) {
  x |>
    gt::as_raw_html(inline_css = FALSE) |>
    gsub(".*?<table.+?>", "<table class=\"table\">", x = _) |>
    gsub("</table>.*", "</table>", x = _)
}
