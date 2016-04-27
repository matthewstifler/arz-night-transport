require(dplyr)
require(rvest)
require(stringr)
require(gdata)
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
bus.intervals = cbind(interval, as.character(bus.list))

#24h:
main.df = read.xls("Borough.xlsx", 1, verbose = TRUE)
buses = as.character(main.df$X24ч)
name = as.character(main.df$Название)
buses.24 = cbind(name, buses) %>% as.data.frame()
buses.24$buses = buses.24$buses %>% as.character() %>% str_replace_all("!", "") %>%
  strsplit(",") %>% trim()
buses.24$buses = lapply(buses.24$buses, tolower)
bus.24.df = read.xls("Borough (1).xlsx", sheet = 2)
bus.24.df = rbind(bus.24.df, data.frame(X6 = "6", X =13))
bus.24.df$X[1:17] = intervals.24[1:17]
colnames(bus.24.df) = c("bus","interval")
bus.24.df$times = round(360 / bus.24.df$interval)
journey.counter = as.numeric(rep(0, 32))
for (i in 1:nrow(buses.24)) { #nested 'for' loops, baaaaad
  for (j in 1:nrow(bus.24.df)){
    journey.counter[i] = journey.counter[i] + ifelse(as.character(bus.24.df$bus[j]) %in% buses.24$buses[[i]], bus.24.df$times[j], 0)
  }
}
buses.24$journeys = journey.counter
buses.24$satur.no.stops = journey.counter / main.df$Площадь..км.2
buses.24$satur.stops = (journey.counter * main.df$Кол.во.остановок)/ main.df$Площадь..км.2
ggplot(aes(x = reorder(name, satur.stops), y = satur.stops), data = buses.24) + geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggplot(aes(x = reorder(name, -satur.no.stops), y = satur.no.stops), data = buses.24) + geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
