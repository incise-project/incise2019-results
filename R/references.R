gen_ds_refs <- function(x) {

  x <- suppressMessages(suppressWarnings(bib2df::bib2df(x)))

  out <- x |>
    dplyr::select(
      author = AUTHOR,
      year = YEAR,
      title = TITLE,
      place = ADDRESS,
      publisher = PUBLISHER,
      doi = DOI,
      url = URL
    ) |>
    dplyr::mutate(
      author = purrr::map_chr(
        .x = author,
        .f = ~glue::glue_collapse(gsub(",", "", .x), sep = ", ", last = " and ")
      ),
      title = gsub("[\\{\\}]", "", title),
      url = dplyr::if_else(is.na(doi), url, paste0("https://doi.org/", doi)),
      output = glue::glue(
        "* {author} ({year}) *{title}*, {place}: {publisher}, [{url}](url)"
      )
    ) |>
    dplyr::arrange(tolower(output))

  out$output

}
