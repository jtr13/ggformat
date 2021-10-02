#' FormatCode
#'
#' Call this function as an addin -- "Reformat ggplot2 code" -- to reformat selected code
#'
#' @export

FormatCode <- function() {

  context <- rstudioapi::getActiveDocumentContext()

  text <- context$selection[[1]]$text

  if(nchar(text) == 0) stop("The selection is empty -- make sure the cursor is in the highlighted selection before running the addin.")

  # GENERAL PREP AND CLEAN UP BEFORE SPLITTING LINES

  # combine into one string
  text <- paste(text, collapse = "")

  # remove line breaks, +,  and trailing white space
  text <- trimws(gsub("\\n|\\+", "", text))

  # remove spaces after (
  text <- gsub("\\(\\s+", "\\(", text)

  # remove spaces before )
  text <- gsub("\\s+\\)", "\\)", text)

  # remove extra spaces after ,
  text <- gsub("\\,\\s+", "\\, ", text)

  # SPLITS

  # split after pipes
  text <- unlist(strsplit(text, split = "(?<=%>%)", perl = TRUE))

  splitwords <- c("geom_", "stat_", "coord_", "facet_", "scale_", "xlim\\(", "ylim\\(", "ggtitle\\(", "labs\\(", "xlab\\(", "ylab\\(", "annotate\\(", "guides", "theme_", "theme\\(")

  split_regex <- paste(splitwords, sep = "", collapse = "|")

  # split at ggplot2 functions, keeping delimiters
  text <- strsplit(text, split = paste0("(?<=.)(?=", split_regex, ")"), perl = TRUE)

  text <- trimws(unlist(text))

  # CREATE DATA FRAME WHICH TO BE USED FOR ORDERING LINES

  df <- data.frame(text)
  nr <- nrow(df)

  # set sort order
  orderwords <- c("firstline", "%>%", "ggplot", splitwords)

   # writeLines(orderwords, "orderwords.txt")  # uncomment, run, and knit Readme.Rmd if orderwords are changed

  order_regex <- paste(orderwords, sep = "", collapse = "|")

  # create a column of tokens for ordering purposes
  df$token <- sub(paste(".*(", order_regex, ").*", sep=""), "\\1", text)

  # override token for first line (in case it's something like g + that is, no special words)
  df$token[1] <- "firstline"

  # set factor levels
  df$token <- factor(df$token, levels = orderwords) # set factor levels

  # order by factor level
  df <- df[order(df$token),]

  # add + to end of lines except last line
  df$text[1:(nr-1)] <- paste(df$text[1:(nr-1)], "+")

  # remove + after pipes (easier than testing first...)
  df$text <- sub("%>% \\+", "%>%", df$text)

  # indent 2nd line on
  df$text[2:nr] <- paste("    ", df$text[2:nr], sep = "")

  # replace text
  rstudioapi::selectionSet(value = df$text, id = context$id)
  }

