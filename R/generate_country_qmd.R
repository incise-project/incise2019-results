# code to generate the country results pages
# country results quarto documents (Z_99_XXX.qmd) are generated using this
# script
#
# inputs:
#   1.  the `countries` vector defines the country names and ordering to use
#       in the report
#   2.  `Z_000_country_template.qmd provides` the skeleton for documents, the
#       country charts are produced via the `country_summary()` function in
#       R/gg_helpers.R
#   3.  `tables/imputation.csv` provides information on the indicators that
#       are fully imputed for select countries
#   4.  the source text for each country's narrative is contained in the
#       markdown files in the `country_narratives` folder
#
# workflow - the script loops over each item in `countries` and does
# the following:
#   1.  extracts the narrative text from the source markdown, separating it
#       into `lead` and `other` content
#   2.  generate page title, modify code chunk for country specific parameters
#   3.  combine template, narrative and generated components
#   4.  output quarto document

# vector of country codes and names
countries <- c(
  "AUS" = "Australia",
  "AUT" = "Austria",
  "BEL" = "Belgium",
  "BGR" = "Bulgaria",
  "CAN" = "Canada",
  "CHL" = "Chile",
  "CZE" = "Czechia",
  "DEU" = "Germany",
  "DNK" = "Denmark",
  "ESP" = "Spain",
  "EST" = "Estonia",
  "FIN" = "Finland",
  "FRA" = "France",
  "GRC" = "Greece",
  "HRV" = "Croatia",
  "HUN" = "Hungary",
  "IRL" = "Ireland",
  "ISL" = "Iceland",
  "ISR" = "Israel",
  "ITA" = "Italy",
  "JPN" = "Japan",
  "KOR" = "Republic of Korea",
  "LTU" = "Lithuania",
  "LVA" = "Latvia",
  "MEX" = "Mexico",
  "NLD" = "Netherlands",
  "NOR" = "Norway",
  "NZL" = "New Zealand",
  "POL" = "Poland",
  "PRT" = "Portugal",
  "ROU" = "Romania",
  "SVK" = "Slovakia",
  "SVN" = "Slovenia",
  "SWE" = "Sweden",
  "CHE" = "Switzerland",
  "TUR" = "Turkey",
  "GBR" = "United Kingdom",
  "USA" = "United States of America"
)

# get common source materials
country_template <- readLines("Z_000_country_template.qmd")
imputation <- readr::read_csv("tables/imputation.csv")

# split the template
title_pos <- which(grepl("!!COUNTRY_TITLE!!", country_template))
template_head <- country_template[1:(title_pos-1)]

for (i in seq_along(countries)) {

  code_chunk <- country_template[(title_pos+1):length(country_template)]

  cc_iso3c <- names(countries[i])

  out_path <- paste0("Z_", sprintf("%02g", i), "_", cc_iso3c, ".qmd")

  country_narrative <- readr::read_lines(
    file.path("country_narratives", paste0(cc_iso3c, ".md"))
  )

  lead_pos <- min(which(country_narrative == ":::"))

  lead_narrative <- country_narrative[1:(min(lead_pos))]
  other_narrative <- country_narrative[(lead_pos+1):length(country_narrative)]

  # page title
  title_text <- paste0(
    "# ", countries[[i]], " {#sec-country-", tolower(cc_iso3c), " .unnumbered}\n"
  )

  # all files need at least country code inserted
  country_params <- paste0("\"", cc_iso3c, "\"")

  # add imputation variables if necessary
  if (cc_iso3c %in% imputation$cc_iso3c) {
    imp_vars <- unlist(strsplit(
      imputation$imputed_vars[imputation$cc_iso3c == cc_iso3c], split = ", "
    ))
    country_params <- paste0(country_params, ", c(", paste0("\"", imp_vars, "\"", collapse = ", "), ")")
  }

  # update code chunk for function parameters and adjust alt text
  code_chunk <- gsub("!!COUNTRY_PARAMS!!", country_params, code_chunk)
  code_chunk <- gsub("!!COUNTRY_NAME!!", countries[[i]], code_chunk)

  out_lines <- c(
    template_head,
    title_text,
    lead_narrative,
    code_chunk,
    other_narrative
  )

  readr::write_lines(out_lines, out_path)

}

nf <- fs::dir_ls("country_narratives/")
fssnap <- tools::md5sum(nf)
saveRDS(fssnap, "country_narratives/.fs_snap")
