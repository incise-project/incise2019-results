incise2019 <- readr::read_csv("tables/incise2019_results.csv")

incise2019_long <- incise2019 |>
  dplyr::bind_rows(
    incise2019 |>
      dplyr::summarise(across(where(is.numeric), mean)) |>
      dplyr::mutate(cc_iso3c = "InCiSE")
  ) |>
  dplyr::select(-cc_name) |>
  tidyr::pivot_longer(cols = -cc_iso3c, names_to = "indicator")

readr::write_csv(incise2019_long, "tables/incise2019_long.csv")
