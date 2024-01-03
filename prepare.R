# preparation script

# check country narratives
old_snap <- readRDS("country_narratives/.fs_snap")
nf <- fs::dir_ls("country_narratives/")
new_snap <- tools::md5sum(nf)

# re-generate country quarto files
if (length(old_snap) > length(new_snap)) {
  stop("Files have been deleted from `country_narratives`")
} else if (length(old_snap) < length(new_snap)) {
  stop("Files have been added to `country_narratives`")
} else if (!identical(old_snap, new_snap)) {
  message("Narratives have changed, generating new country files")
  #source("R/generate_country_qmd.R")
} else {
  message("Country narratives unchanged")
}
