require("rgdal", "dplyr")

# get stops coordinates
setwd("~/arz-night-transport")
busstops = read.csv("bus-stops-10-06-15.csv")

#setting grid systems, gotta convert ukgrid to latlong
ukgrid = "+init=epsg:27700"
latlong = "+init=epsg:4326"

# load wards shapefiles
# run ingress snippet (might fire back!) for id'ing in which shape what lies
# get n of stations for each ward