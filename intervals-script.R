require(dplyr)
require(rvest)
require(stringr)
###getting bus intervals
#night:
#parse from wiki by this tutorial http://www.r-bloggers.com/using-rvest-to-scrape-an-html-table/
interval = as.numeric()
page = read_html("https://en.wikipedia.org/wiki/List_of_night_buses_in_London")
for (i in 3:4) {
  xpath.str = str_c('//*[@id="mw-content-text"]/table[') %>% str_c(i) %>% str_c("]")
  bus.table = html_nodes(page, xpath = xpath.str) %>% html_table() 
  bus.table = bus.table[[1]]
  if (nrow(bus.table) == 16) { #if 16 - no weekend frequency
    interval[i] = bus.table[,2][14] %>% str_extract("[:digit:]*")
  } else {
    interval[i] = bus.table[,2][15] %>% str_extract("[:digit:]*")
  }
}
interval = interval[3:length(interval)]
cbind(interval, as.character(bus.list)) %>% View()

#24h: