# InCiSE 2019 Results Report

This repository contains source code needed to produce an HTML version of the
2019 Results Report of the InCiSE project. You can read the rendered HTML
book [here](https://incise-project.github.io/incise2019-results). You
can also download the
[original PDF publication](https://incise-project.github.io/incise2019-results/incise2019_results_report.pdf).

This repo relates to the InCiSE Index 2019 Results Report, there is a separate
[repo](https://github.com/incise-project/incise2019-techreport) and
[HTML book](https://incise-project.github.io/incise2019-techreport/) for the
Technical Report which discusses the methodology behind the InCiSE Index.

## About

From 2016 to 2019, the
[International Civil Service Effectiveness (InCiSE) project](https://www.bsg.ox.ac.uk/incise)
was a collaboration between the
[Blavatnik School of Government](https://www.bsg.ox.ac.uk) and the
[Institute for Government](http://instituteforgovernment.org.uk).
It was supported by the UK Civil Service (through the
[Cabinet Office](https://www.gov.uk/cabinetoffice)) and funded by the
[Open Society Foundations](https://www.opensocietyfoundations.org).

The Blavatnik School of Government is re-establishing the InCiSE project with
the aim of publishing a new edition of the InCiSE Index in 2024. To support
engagement with stakeholders the School is re-publishing the 2019 project
outputs (this Technical Report, the Results Report and interactive data
visualisations) in more modern and user friendly formats.

### Differences from the original 2019 publication

Some typographic errors have been corrected as part of the re-publication of
this report. There have also been some changes to the tables and figures when
compared to the original report, these are largely for layout purposes.
Footnotes have been added to charts, tables and chapters to indicate changes in
content and differences in numbering.

Please note, as part of the re-publication of this report into a web format
Chapter 4 of the original report has been reproduced as interactive content,
static versions of this content are also provided in the Appendices.

## Citation

Please refer to and cite the original PDF publication:

> InCiSE Partners (2019) The International Civil Service Effectiveness (InCiSE)
> Index: Results Report 2019, Oxford: Blavatnik School of Government,
> University of Oxford, https://www.bsg.ox.ac.uk/incise

## Copyright & licensing

The original report content and data are the joint copyright of the InCiSE
Partners - the Blavatnik School of Government (University of Oxford),
the Institute for Government, and the UK Civil Service (through the Cabinet
Office). The report content contained in this reproduction is released under
the [CC-BY-4.0](LICENSE) license.

The source code to process data and produce the report is released under the
[MIT License](LICENSE-CODE).

## Developer notes

This re-production of the report has been made in [Quarto](http://quarto.org)
with [R](https://r-project.org).

### Quarto publishing

The book is rendered and published to GitHub Pages using GitHub Actions.
Note computations are processed locally and
[frozen](https://quarto.org/docs/publishing/github-pages.html#freezing-computations)
by Quarto.

The PDF publication available in this repo has not rendered via Quarto. It is a
copy of the originally published PDF report.

### Tables and figures

Data for the source tables and computed charts is contained in the
[`tables`](tables/) folder. Most of these are stored as markdown format text
files, i.e pipe (`|`) delimited with a header separator (`===`).
Especially text heavy tables that may have a significant number of
commas in the table text. Otherwise tables are stored as CSV files. Use the
custom `read_md_tbl()` function (see below) to read these tables into R.

Other images are contained in the [`figures`](figures/) folder.

### Custom R functions and processing scripts

The [`R`](R/) folder contains a number of custom functions and processing
scripts for constructing the book:

#### Functions

[`gen_contents.R`](gen_contents.R) contains a set of helper functions to
produce the tables of contents, list of figures and list of tables included in
[`contents.qmd`](contents.qmd).

[`gg_helpers.R`](R/gg_helpers.R) provides a function to include a `{ggplot2}`
chart as raw SVG to make it more accessible (i.e. as SVG tags rather than SVG
content provided as base64 content inside an `<img>` tag, the Quarto/knitr
default). It is a modified version of
[`govukhugo::render_svg()`](https://github.com/co-analysis/govukhugo-r/blob/ae27cf184e2b5470b97388800e13c74a38310d4d/R/images.R).

[`references.R`](R/references.R) provides functions to produce the custom
reference lists of data sources included in 
[`B_data_sources.qmd`](B_data_sources.qmd).

[`tbl_helpers.R`](R/tbl_helpers.R) provides a set of functions to help process
and render tables in the book:

* `read_md_tbl()` is a wrapper around `readr::read_delim()` to read tables
  saved in markdown format (i.e. pipe delimited).
* `convert_percent()` is a convenience function convert string percentages into
  doubles.
* `rag_image()` is a formatter function for working with `gt::fmt()` to convert
  display red/amber/green (RAG) rating icons in a column.
* `strip_gt()` is a function to strip a `gt::gt()` object of its custom CSS
  styles so the HTML table is rendered and styled by Quarto.
* `fmt_maxmin()` is a function to apply conditional styling to the maximum and
  minimum cell values of a `{gt}` table.

#### Processing scripts

[`country_visuals.R`](R/country_visuals.R) is a script to produce the CSV files
that are used by the interactive charts in
[`04_00_country_profiles.qmd`](04_00_country_profiles.qmd).

[`generate_country_qmd.R`](R/generate_country_qmd.R) is a script to
programmatically generate the the country profile pages of the report
(`Z_99_XXX.qmd` files). This uses the country template file
([`Z_000_country_template.qmd`](04_000_country_template.qmd)) and inserts
the relevant country parameters for creating the chart output and appends the
narrative information included in the country narrative markdown documents
stored in the [`country_narratives`](country_narratives) folder.

[`long_data.R`](R/long_data.R) is a script that reprocesses the InCiSE
results into a long-format CSV that is more suitable chart production.

[`prepare.R`](prepare.R) is a script in the root directory that is used by
the Quarto rendering engine to detect whether the country narratives have been
updated and if they have to re-run the creation of the country profile pages.

### Session info

```r
sessioninfo::session_info()
#> ─ Session info ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.3.1 (2023-06-16)
#>  os       macOS Ventura 13.6.1
#>  system   x86_64, darwin20
#>  ui       RStudio
#>  language (EN)
#>  collate  en_US.UTF-8
#>  ctype    en_US.UTF-8
#>  tz       Europe/London
#>  date     2024-01-03
#>  rstudio  2023.09.1+494 Desert Sunflower (desktop)
#>  pandoc   3.1.1 @ /Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/ (via rmarkdown)
#> 
#> ─ Packages ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#>  package      * version date (UTC) lib source
#>  bib2df         1.1.1   2019-05-22 [1] CRAN (R 4.3.0)
#>  bit            4.0.5   2022-11-15 [1] CRAN (R 4.3.0)
#>  bit64          4.0.5   2020-08-30 [1] CRAN (R 4.3.0)
#>  cli            3.6.1   2023-03-23 [1] CRAN (R 4.3.0)
#>  colorspace     2.1-0   2023-01-23 [1] CRAN (R 4.3.0)
#>  crayon         1.5.2   2022-09-29 [1] CRAN (R 4.3.0)
#>  digest         0.6.33  2023-07-07 [1] CRAN (R 4.3.0)
#>  dplyr          1.1.3   2023-09-03 [1] CRAN (R 4.3.0)
#>  evaluate       0.23    2023-11-01 [1] CRAN (R 4.3.0)
#>  fansi          1.0.5   2023-10-08 [1] CRAN (R 4.3.0)
#>  farver         2.1.1   2022-07-06 [1] CRAN (R 4.3.0)
#>  fastmap        1.1.1   2023-02-24 [1] CRAN (R 4.3.0)
#>  forcats        1.0.0   2023-01-29 [1] CRAN (R 4.3.0)
#>  formattable    0.2.1   2021-01-07 [1] CRAN (R 4.3.0)
#>  fs             1.6.3   2023-07-20 [1] CRAN (R 4.3.0)
#>  generics       0.1.3   2022-07-05 [1] CRAN (R 4.3.0)
#>  ggplot2      * 3.4.4   2023-10-12 [1] CRAN (R 4.3.0)
#>  glue           1.6.2   2022-02-24 [1] CRAN (R 4.3.0)
#>  gt             0.10.0  2023-10-07 [1] CRAN (R 4.3.0)
#>  gtable         0.3.4   2023-08-21 [1] CRAN (R 4.3.0)
#>  here           1.0.1   2020-12-13 [1] CRAN (R 4.3.0)
#>  hms            1.1.3   2023-03-21 [1] CRAN (R 4.3.0)
#>  htmltools      0.5.6.1 2023-10-06 [1] CRAN (R 4.3.0)
#>  htmlwidgets    1.6.2   2023-03-17 [1] CRAN (R 4.3.0)
#>  httr           1.4.7   2023-08-15 [1] CRAN (R 4.3.0)
#>  humaniformat   0.6.0   2016-04-24 [1] CRAN (R 4.3.0)
#>  jsonlite       1.8.7   2023-06-29 [1] CRAN (R 4.3.0)
#>  knitr          1.45    2023-10-30 [1] CRAN (R 4.3.0)
#>  labeling       0.4.3   2023-08-29 [1] CRAN (R 4.3.0)
#>  later          1.3.1   2023-05-02 [1] CRAN (R 4.3.0)
#>  lifecycle      1.0.3   2022-10-07 [1] CRAN (R 4.3.0)
#>  magrittr       2.0.3   2022-03-30 [1] CRAN (R 4.3.0)
#>  munsell        0.5.0   2018-06-12 [1] CRAN (R 4.3.0)
#>  patchwork    * 1.1.3   2023-08-14 [1] CRAN (R 4.3.0)
#>  pillar         1.9.0   2023-03-22 [1] CRAN (R 4.3.0)
#>  pkgconfig      2.0.3   2019-09-22 [1] CRAN (R 4.3.0)
#>  processx       3.8.2   2023-06-30 [1] CRAN (R 4.3.0)
#>  ps             1.7.5   2023-04-18 [1] CRAN (R 4.3.0)
#>  purrr          1.0.2   2023-08-10 [1] CRAN (R 4.3.0)
#>  quarto         1.3     2023-09-19 [1] CRAN (R 4.3.0)
#>  R6             2.5.1   2021-08-19 [1] CRAN (R 4.3.0)
#>  ragg           1.2.6   2023-10-10 [1] CRAN (R 4.3.0)
#>  Rcpp           1.0.11  2023-07-06 [1] CRAN (R 4.3.0)
#>  readr          2.1.4   2023-02-10 [1] CRAN (R 4.3.0)
#>  rlang          1.1.1   2023-04-28 [1] CRAN (R 4.3.0)
#>  rmarkdown      2.25    2023-09-18 [1] CRAN (R 4.3.0)
#>  rprojroot      2.0.4   2023-11-05 [1] CRAN (R 4.3.0)
#>  rstudioapi     0.15.0  2023-07-07 [1] CRAN (R 4.3.0)
#>  sass           0.4.7   2023-07-15 [1] CRAN (R 4.3.0)
#>  scales         1.2.1   2022-08-20 [1] CRAN (R 4.3.0)
#>  sessioninfo    1.2.2   2021-12-06 [1] CRAN (R 4.3.0)
#>  stringi        1.7.12  2023-01-11 [1] CRAN (R 4.3.0)
#>  stringr        1.5.0   2022-12-02 [1] CRAN (R 4.3.0)
#>  svglite        2.1.2   2023-10-11 [1] CRAN (R 4.3.0)
#>  systemfonts    1.0.5   2023-10-09 [1] CRAN (R 4.3.0)
#>  textshaping    0.3.7   2023-10-09 [1] CRAN (R 4.3.0)
#>  tibble         3.2.1   2023-03-20 [1] CRAN (R 4.3.0)
#>  tidyr          1.3.0   2023-01-24 [1] CRAN (R 4.3.0)
#>  tidyselect     1.2.0   2022-10-10 [1] CRAN (R 4.3.0)
#>  tzdb           0.4.0   2023-05-12 [1] CRAN (R 4.3.0)
#>  utf8           1.2.4   2023-10-22 [1] CRAN (R 4.3.0)
#>  vctrs          0.6.4   2023-10-12 [1] CRAN (R 4.3.0)
#>  vroom          1.6.4   2023-10-02 [1] CRAN (R 4.3.0)
#>  withr          2.5.2   2023-10-30 [1] CRAN (R 4.3.0)
#>  xfun           0.41    2023-11-01 [1] CRAN (R 4.3.0)
#>  xml2           1.3.5   2023-07-06 [1] CRAN (R 4.3.0)
#>  yaml           2.3.7   2023-01-23 [1] CRAN (R 4.3.0)
#> 
#>  [1] $USER_LIBRARY
#>  [2] /Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/library

quarto::quarto_version()
#> [1] ‘1.3.433’
```
