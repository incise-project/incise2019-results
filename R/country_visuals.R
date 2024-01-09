
# country narratives df ---------------------------------------------------

narratives <- fs::dir_ls("country_narratives/")

narratives_raw <- purrr::map_dfr(
  .x = narratives,
  .f = ~tibble::tibble(cc_iso3c = .x, text = readr::read_lines(.x))
)

narratives_text <- narratives_raw |>
  dplyr::mutate(
    section = dplyr::case_when(
      grepl(":::\\{.lead\\}", text) ~ "section_lead",
      grepl("::: \\{.callout-note .crf ", text) ~ "section_xref",
      grepl("^:::$", text) ~ "section_end"
    ),
    section_marker = !is.na(section)
  ) |>
  dplyr::mutate(
    section = cumsum(section_marker),
    .by = "cc_iso3c"
  ) |>
  dplyr::filter(!section_marker) |>
  dplyr::summarise(
    text = paste0(text, collapse = "\n"),
    .by = c("cc_iso3c", "section")
  ) |>
  dplyr::mutate(
    section = dplyr::case_match(
      section,
      1 ~ "lead_text",
      2 ~ "body_text",
      3 ~ "xref_note"
    ),
    cc_iso3c = gsub("\\.md", "", basename(cc_iso3c)),
    text = stringr::str_trim(text),
    text = gsub("\\n", " ", text)
  ) |>
  tidyr::pivot_wider(names_from = "section", values_from = "text") |>
  dplyr::mutate(
    xref_note = gsub(".*(section 4\\.\\d+).*", "\\1", xref_note)
  )

readr::write_excel_csv(narratives_text, "country_visuals/country_narratives.csv")



# radar data --------------------------------------------------------------

incise2019_long <- readr::read_csv("tables/incise2019_long.csv")

imputation <- readr::read_csv("tables/imputation.csv")

imputatation_df <- imputation |>
  tidyr::separate_rows(imputed_vars, sep = ", ") |>
  dplyr::mutate(
    indicator = paste0("ind_", tolower(imputed_vars)),
    imputed = TRUE
  ) |>
  dplyr::select(-imputed_vars)

radar_df <- incise2019_long |>
  dplyr::filter(indicator != "incise_index") |>
  dplyr::left_join(imputatation_df, by = c("cc_iso3c", "indicator")) |>
  dplyr::mutate(
    imputed = value * imputed,
    indicator = dplyr::case_match(
      indicator,
      "ind_cap" ~ "Capabilities",
      "ind_crm" ~ "Crisis and risk management",
      "ind_dig" ~ "Digital services",
      "ind_ffm" ~ "Fiscal and financial management",
      "ind_hrm" ~ "HR management",
      "ind_inc" ~ "Inclusiveness",
      "ind_int" ~ "Integrity",
      "ind_opn" ~ "Openness",
      "ind_pol" ~ "Policy making",
      "ind_pro" ~ "Procurement",
      "ind_reg" ~ "Regulation",
      "ind_tax" ~ "Tax administration"
    ),
    indicator = stringr::str_wrap(indicator, 13),
    indicator = forcats::as_factor(indicator),
    theta = as.numeric(indicator),
    theta = (360*(theta/max(theta))-105) * pi / 180,
    new_x = cos(theta) * value,
    new_y = sin(theta) * -value,
    value = dplyr::if_else(!is.na(imputed), NA_real_, value),
    data_label = dplyr::if_else(
      is.na(value),
      paste0(cc_iso3c, " - ", indicator, ": ", scales::comma(imputed, accuracy = 0.01), " (imputed)"),
      paste0(cc_iso3c, " - ", indicator, ": ", scales::comma(value, accuracy = 0.01))
    ),
    data_label = stringr::str_wrap(data_label, 20)
  )

radar_values <- radar_df |>
  dplyr::filter(!is.na(value))

radar_imputed <- radar_df |>
  dplyr::filter(!is.na(imputed))

readr::write_excel_csv(radar_df, "country_visuals/radar_data_full.csv")
readr::write_excel_csv(radar_imputed, "country_visuals/radar_imputed.csv")

radar_axes <- radar_df |>
  dplyr::distinct(indicator) |>
  dplyr::mutate(
    theta = as.numeric(indicator),
    theta = (360*(theta/max(theta))-105) * pi / 180,
    label_x = cos(theta) * 1.2,
    label_y = sin(theta) * -1.2,
    axis_x = cos(theta) * 1.05,
    axis_y = sin(theta) * -1.05,
  )

readr::write_excel_csv(radar_axes, "country_visuals/radar_axes.csv")

radar_grid <- radar_df |>
  dplyr::distinct(indicator) |>
  dplyr::mutate(
    theta = as.numeric(indicator),
    theta = (360*(theta/max(theta))-105) * pi / 180,
    grids = 4
  ) |>
  tidyr::uncount(grids) |>
  dplyr::mutate(
    grid = seq(1, 4)/4,
    .by = "indicator"
  ) |>
  dplyr::mutate(
    grid_x = cos(theta) * grid,
    grid_y = sin(theta) * grid
  )

readr::write_excel_csv(radar_grid, "country_visuals/radar_grid.csv")


# bar data ----------------------------------------------------------------

bar_df <- incise2019_long |>
  dplyr::filter(indicator == "incise_index") |>
  dplyr::mutate(
    value_label = scales::comma(value, accuracy = 0.01),
    hover_label = paste0(cc_iso3c, ": ", value_label)
  )

readr::write_excel_csv(bar_df, "country_visuals/bar_data.csv")
