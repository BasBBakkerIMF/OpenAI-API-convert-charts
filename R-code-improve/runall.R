# Run every chart script in this folder and list the ones that failed.
# Run with this folder as the working directory (open R-code-improve.Rproj).

scripts <- list.files(pattern = "^fig-.*\\.R$")
# Order by figure number, so fig-2-3 comes before fig-10-1.
figure_number <- function(f) {
  parts <- as.integer(strsplit(sub("^fig-(.*)\\.R$", "\\1", f), "-")[[1]])
  sum(parts * c(1e4, 1e2, 1)[seq_along(parts)])
}
scripts <- scripts[order(sapply(scripts, figure_number))]

errors <- character()
for (script in scripts) {
  tryCatch(
    source(script, local = new.env()),
    error = function(e) {
      message("ERROR in ", script, ": ", conditionMessage(e))
      errors[script] <<- conditionMessage(e)
    }
  )
}

cat("\n============================\nFILES WITH ERRORS\n============================\n")
if (length(errors) == 0) {
  cat("None\n")
} else {
  cat(paste0(names(errors), " -- ", errors, "\n"), sep = "")
}
cat(length(scripts) - length(errors), "of", length(scripts), "charts created.\n")
