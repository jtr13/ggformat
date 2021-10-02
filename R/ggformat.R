#' Reformat ggplot2 code
#'
#'
#' @export

FormatCode <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  text <- context$selection[[1]]$text
  if(nchar(text) == 0) stop("The selection is empty -- make sure the cursor is in the highlighted selection before running the addin.")
  text <- paste(text, collapse = "") # combine into one string
  text <- trimws(gsub("\\n|\\+", "", text)) # remove line breaks, +,  and trailing white space
  text <- gsub("\\(\\s+", "\\(", text) # remove spaces after (
  text <- gsub("\\s+\\)", "\\)", text) # remove spaces before )
  text <- gsub("\\,\\s+", "\\, ", text) # remove extra spaces after ,

  words <- c("firstline", "ggplot", "geom_", "stat_", "coord_", "facet_", "scale_", "xlim\\(", "ylim\\(", "ggtitle\\(", "labs\\(", "xlab\\(", "ylab\\(", "theme_", "theme\\(")
  save(words, file = "words.rda")
  words_regex <- paste(words, sep = "", collapse = "|")
  # split at ggplot2 functions, keeping delimiters
  text <- strsplit(text, paste0("(?<=.)(?=", words_regex, ")"), perl = TRUE)
  text <- trimws(unlist(text))

  df <- data.frame(text)
  nr <- nrow(df)
  # create a column of ggplot2 functions
  df$func <- sub(paste(".*(", words_regex, ").*", sep=""), "\\1", text)
  df$func[1] <- "firstline" # override any matches in first line
  df$func <- factor(df$func, levels = words) # set factor levels
  df <- df[order(df$func),] # order by factor level

  df$text[1:(nr-1)] <- paste(df$text[1:(nr-1)], "+") # add + to end of lines except last line
  df$text[1] <- sub("%>% \\+", "%>%", df$text[1]) # remove + after pipe in first line
  df$text[2:nr] <- paste("    ", df$text[2:nr], sep = "") # index 2nd line on
  rstudioapi::selectionSet(value = df$text, id = context$id) # replace text

}
