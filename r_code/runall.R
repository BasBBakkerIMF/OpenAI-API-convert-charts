chart_stems <- c(
    "fig-1-1",
    "fig-1-2",
    "fig-2-1",
    "fig-2-2",
    "fig-2-3",
    "fig-2-4",
    "fig-3-1",
    "fig-3-2",
    "fig-3-3",
    "fig-3-4",
    "fig-4-0",
    "fig-5-1",
    "fig-5-2",
    "fig-6-1",
    "fig-6-2",
    "fig-7-1",
    "fig-7-2",
    "fig-8-0",
    "fig-9-1",
    "fig-9-2",
    "fig-10-1",
    "fig-10-2",
    "fig-11-1",
    "fig-11-2",
    "fig-12-1",
    "fig-13-0",
    "fig-14-1",
    "fig-14-2",
    "fig-15-1",
    "fig-15-2",
    "fig-16-1",
    "fig-16-2",
    "fig-1-1-1",
    "fig-1-1-2",
    "fig-1-2-1",
    "fig-1-2-2",
    "fig-1-2-3",
    "fig-1-3-1"
)

failed_files <- character()
error_messages <- character()

for (stem in chart_stems) {

    file <- paste0("K:/r_code/", stem, ".R")

    tryCatch(
        source(file),
        error = function(e) {

            message(
                "ERROR in ",
                file,
                ": ",
                e$message
            )

            failed_files <<- c(
                failed_files,
                file
            )

            error_messages <<- c(
                error_messages,
                e$message
            )
        }
    )
}

cat("\n")
cat("============================\n")
cat("FILES WITH ERRORS\n")
cat("============================\n")

if (length(failed_files) == 0) {

    cat("None\n")

} else {

    for (i in seq_along(failed_files)) {

        cat(
            failed_files[i],
            " -- ",
            error_messages[i],
            "\n",
            sep = ""
        )
    }
}
