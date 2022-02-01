#' File containing the code to creat html and pdf versions
#' of the book.

#' Gitbook for html viewing

#' This will generate the book
bookdown::render_book("index.Rmd", "bookdown::gitbook")

#' To open the html (gitbook) version of the book.
browseURL("_book/introduction.html")

#' To create pdf version
bookdown::render_book("index.Rmd", bookdown::pdf_book())

#' Best to use serve_book when working on the chapters
bookdown::serve_book()
