tab_num<-124

url_query<-paste0("C:/Users/iryku/Trøndelag fylkeskommune/Seksjon Regional - Statistikk/PowerBI/GitHub/query-nsd/", tab_num, ".json")
query<-jsonlite::fromJSON(url_query)

url_tabell <- "https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=001"
oversk_tabell <- httr::content(httr::GET(url_tabell), as = "text", encoding = "UTF-8")
oversk_tabell <-
  readr::read_delim( oversk_tabell, delim = ",", col_types = readr::cols(.default = readr::col_character()), na = "",
    trim_ws = TRUE, progress = FALSE)

oversk_tabell<-as.data.frame(oversk_tabell)



for( i in 1:length(names(oversk_tabell))){
  if (names(oversk_tabell)[i]=="Tabell id") names(oversk_tabell)[i]<-"TabellID"
}
tab_num<-as.character(tab_num)


if (!isTRUE(dplyr::filter(oversk_tabell, TabellID==tab_num)["Bulk tabell"])) {
  res <-httr::POST(url = "https://api.nsd.no/dbhapitjener/Tabeller/streamCsvData",
                   httr::add_headers(`Content-Type` = "application/json",
                                     Authorization = paste("Bearer", "", sep =  " ")),
                   body = query,
                   encode = "json")
  delim_res<-";"
} else {
  url <-
    paste0("https://api.nsd.no/dbhapitjener/Tabeller/bulk-csv?rptNr=", table_num)
  temp_file <- tempfile()
  on.exit(unlink(temp_file))
  utils::download.file(url, quiet = TRUE, 
                       destfile = temp_file,
                       headers = c(Authorization =
                                     paste("Bearer", "", sep = " ")))
  res <- temp_file
  delim_csv <- ","
  
}



res<-httr::content(res, "text", encoding = "UTF-8")
data <-
  readr::read_delim(res, delim = delim_res, col_types = readr::cols(.default = readr::col_character()), 
    locale = readr::locale(decimal_mark = "."), na = "", trim_ws = TRUE
  )




