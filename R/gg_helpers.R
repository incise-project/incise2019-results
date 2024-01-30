# function to insert plot as raw svg code
# a modified from render_svg from @co-analysis/govukhugo-r
# https://github.com/co-analysis/govukhugo-r/blob/ae27cf184e2b5470b97388800e13c74a38310d4d/R/images.R

render_svg <- function(plot, width, height, units = "px",
                       alt_text = NULL, source_note = NULL, dpi = 72) {

  # {ggplot2} is in suggests to reduce install bloat
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("render_svg() requires package {ggplot2} to be installed.",
         call. = FALSE)
  }

  # {svglite} is in suggests to reduce install bloat
  if (!requireNamespace("svglite", quietly = TRUE)) {
    stop("render_svg() requires package {svglite} to be installed.",
         call. = FALSE)
  }

  # warn if no alt text provided
  if (is.null(alt_text)) {
    warning("You have not provided any alt text for the plot, please reconsider.")
  }

  # create a temporary file
  svg_file <- paste0(tempfile(),".svg")

  # check ggplot2 version
  # if less than 3.3.5 convert px units to mm
  ggplot_version <- as.character(utils::packageVersion("ggplot2"))

  if (utils::compareVersion(ggplot_version, "3.3.5") == -1) {
    if (units == "px") {
      width <- width * (25.4/dpi)
      height <- height * (25.4/dpi)
      units <- "mm"
    }
  }

  # render ggplot as an svg
  ggplot2::ggsave(svg_file, plot, device = "svg",
                  width = width, height = height, units = units, dpi = dpi)

  # read the svg, drop the DOCTYPE declaration
  x <- readLines(svg_file)[-1]

  # remove explicit width/height settings
  x[1] <- gsub("(width|height)='.*?' ", "", x[1])

  # generate a unique id for the object
  unique_id <- paste0(c(sample(letters, 5), replicate(5, sample(0:9, 3))),
                      collapse = "")

  # create tags for alt_title
  if (!is.null(alt_text)) {
    described_by <- paste0(" aria-labelledby='", unique_id, "-desc'")
    alt_insert <- paste0("<desc id='", unique_id, "-desc'>", alt_text,
                         "</desc>")
  }

  # insert alt text tags into svg, if no alt_text still set role='img'
  if (!is.null(alt_text)) {
    x1 <- gsub(">", paste0(described_by," role='img' style='width: ", width,
                           "px; height: ", height, "px'>"), x[1])
    new_svg <- c(x1, alt_insert, x[2:length(x)])
  } else {
    x1 <- gsub(">", " role='img' style='width: ", width,
               "px; height: ", height, "px'>", x[1])
    new_svg <- c(x1, x[2:length(x)])
  }

  # strip out text box adjustment
  new_svg <- gsub("textLength\\S+ ", "", new_svg)

  out_chunk <- paste(new_svg, sep = "\n")

  # render as an HTML object, add source note if provided
  if (is.null(source_note)) {
    htmltools::HTML(out_chunk)
  } else {
    source_note <- paste0("<div class='source-note'>",
                          source_note,
                          "</div>", collapse = "")
    htmltools::HTML(c(out_chunk, source_note))
  }



}

indicator_bar <- function(df, ind) {

  ind <- paste0("ind_", tolower(ind))

  gdf <- df |>
    dplyr::filter(indicator == ind) |>
    dplyr::mutate(
      cc_iso3c = forcats::fct_reorder(cc_iso3c, value),
    )

  gdf_overlay <- gdf |>
    dplyr::filter(cc_iso3c == "InCiSE") |>
    dplyr::mutate(group = "InCiSE")

  gdf_top5 <- gdf |>
    dplyr::slice_max(value, n = 5) |>
    dplyr::mutate(group = "top5")

  gdf <- gdf |>
    dplyr::mutate(
      axis_text = dplyr::case_when(
        cc_iso3c == "InCiSE" ~ NA_character_,
        cc_iso3c %in% gdf_top5$cc_iso3c ~ NA_character_,
        TRUE ~ cc_iso3c
      ),
      group = dplyr::case_when(
        cc_iso3c == "InCiSE" ~ "InCiSE",
        cc_iso3c %in% gdf_top5$cc_iso3c ~ "top5",
        TRUE ~ "other"
      )
    )


  p <- ggplot(gdf, aes(x = value, y = cc_iso3c)) +
    geom_col(aes(fill = group)) +
    geom_text(aes(label = axis_text, x = -0.01, colour = group),
              family = "Open Sans", hjust = 1, size = 4) +
    geom_text(data = gdf_overlay,
              aes(label = cc_iso3c, colour = group, x = -0.01),
              family = "Open Sans", fontface = "bold", hjust = 1, size = 4) +
    geom_text(data = gdf_top5,
              aes(label = cc_iso3c, colour = group, x = -0.01),
              family = "Open Sans", fontface = "bold", hjust = 1, size = 4) +
    geom_text(data = gdf_overlay,
              aes(label = scales::number(value, 0.01), colour = group),
              nudge_x = 0.01,
              family = "Open Sans", fontface = "bold", hjust = 0, size = 4) +
    scale_x_continuous(expand = expansion(add = c(0.2, 0))) +
    scale_fill_manual(values = c(
      "other" = "#dddddd",
      "top5" = "#00629B",
      "InCiSE" = "#C4622D"
    )) +
    scale_colour_manual(values = c(
      "other" = "#444444",
      "top5" = "#00629B",
      "InCiSE" = "#C4622D"
    )) +
    theme_void() +
    theme(
      legend.position = "none"
    )

  return(p)

}


country_summary <- function(df, country, imputation = NULL) {

  bar_gdf <- df |>
    dplyr::filter(indicator == "incise_index") |>
    dplyr::mutate(
      group = dplyr::case_when(
        cc_iso3c == "InCiSE" ~ "InCiSE",
        cc_iso3c == country ~ "country",
        TRUE ~ "other"
      ),
      axis_text = dplyr::if_else(group == "other", cc_iso3c, NA_character_),
      axis_emphasis = dplyr::if_else(group == "other", NA_character_, cc_iso3c),
      value_label = dplyr::if_else(group == "other",
                                   NA_character_,
                                   scales::number(value, 0.01)),
      cc_iso3c = forcats::fct_reorder(cc_iso3c, value)
    )

  bar_plot <- ggplot(bar_gdf, aes(x = value, y = cc_iso3c)) +
    geom_col(aes(fill = group)) +
    geom_text(aes(label = axis_text, x = -0.01, colour = group),
              family = "Open Sans",
              hjust = 1, size = 4) +
    geom_text(aes(label = axis_emphasis, x = -0.01, colour = group),
              family = "Open Sans", fontface = "bold",
              hjust = 1, size = 4) +
    geom_text(aes(label = value_label, colour = group),
              fontface = "bold", family = "Open Sans",
              nudge_x = 0.02, hjust = 0, size = 4) +
    scale_x_continuous(expand = expansion(add = c(0.2, 0))) +
    scale_fill_manual(values = c(
      "country" = "#00629B",
      "InCiSE" = "#C4622D",
      "other" = "#dddddd"
    )) +
    scale_colour_manual(values = c(
      "country" = "#00629B",
      "InCiSE" = "#C4622D",
      "other" = "#444444"
    )) +
    theme_void() +
    theme(
      legend.position = "none"
    )

  if (!is.null(imputation)) {
    imp_inds <- paste0("ind_", tolower(imputation))
  } else {
    imp_inds <- character()
  }

  radar_df <- incise2019_long |>
    dplyr::filter(
      (cc_iso3c == country | cc_iso3c == "InCiSE") &
        indicator != "incise_index"
    ) |>
    dplyr::mutate(
      point_shape = dplyr::if_else(
        .data$cc_iso3c == country & .data$indicator %in% imp_inds,
        "impute",
        "full"
      ),
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
        "ind_tax" ~ "Tax administration",
      ),
      indicator = stringr::str_wrap(indicator, 13),
      indicator = forcats::as_factor(indicator),
      theta = as.numeric(indicator),
      theta = (360*(theta/max(theta))-105) * pi / 180,
      new_x = cos(theta) * value,
      new_y = sin(theta) * -value,
      group = dplyr::if_else(cc_iso3c == "InCiSE", "InCiSE", "country"),
      fill_group = paste(group, point_shape, sep = "_"),
      group = forcats::fct_rev(group)
    ) |>
    dplyr::arrange(group, indicator)



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

  radar_plot <- ggplot(radar_df, aes(x = new_x, y = new_y, group = group,
                                     colour = group)) +
    geom_polygon(data = radar_grid, aes(x = grid_x, y = grid_y, group = grid),
                 inherit.aes = FALSE, fill = NA, colour = "#dddddd") +
    geom_segment(data = radar_axes,
                 aes(x = 0, y = 0, xend = axis_x, yend = axis_y),
                 inherit.aes = FALSE, colour = "#dddddd") +
    geom_polygon(aes(linewidth = group, linetype = group, group = group), fill = NA,
                 key_glyph = "path") +
    geom_point(aes(fill = fill_group), stroke = 1.5, shape = 21, size = 3.25) +
    geom_text(data = radar_axes,
              aes(x = label_x, y = label_y, label = indicator, group = indicator),
              colour = "#444444", size = 4) +
    scale_colour_manual(
      values = c(
        "country" = "#00629B",
        "InCiSE" = "#C4622D"
      )
    ) +
    scale_fill_manual(
      values = c(
        "country_full" = "#00629B",
        "country_impute" = "#ffffff",
        "InCiSE_full" = "#C4622D"
      )
    ) +
    scale_linewidth_manual(
      values = c(
        "country" = 1.5,
        "InCiSE" = 0.75
      )
    ) +
    scale_linetype_manual(
      values = c(
        "country" = "solid",
        "InCiSE" = "dashed"
      )
    ) +
    coord_fixed(xlim = c(-1.25, 1.25), ylim = c(-1.25, 1.25)) +
    theme_void() +
    theme(
      text = element_text(family = "Open Sans", colour = "#444444", size = 14),
      legend.position = "none"
    )

  combined_plot <- bar_plot + radar_plot +
    plot_layout(widths = c(1, 2))

  return(combined_plot)

}
