# preparation script

# re-generate country quarto files
old_snap <- readRDS("country_narratives/.fs_snap")
snap_chk <- utils::changedFiles(before = old_snap)

if (length(snap_chk$changed) > 0) {
  source("R/generate_country_qmd.R")
} else if (length(snap_chk$added) > 0) {
  stop("Files have been added to `country_narratives`")
} else if (length(snap_chk$deleted) > 0) {
  stop("Files have been deleted from `country_narratives`")
}

