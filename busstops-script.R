require("rgdal", "dplyr")
require(ggmap)
require(mapproj)
require(stringr)
# get stops coordinates
setwd("~/arz-night-transport")
busstops = read.csv("bus-stops-10-06-15.csv")
busstops = busstops[,c(2,4:6)]
colnames(busstops) = c("id","name","easting","northing")

#setting grid systems, gotta convert ukgrid to latlong
ukgrid = "+init=epsg:27700"
latlong = "+init=epsg:4326"

coords = cbind(Easting = as.numeric(as.character(busstops$easting)),
                Northing = as.numeric(as.character(busstops$northing)))
busstops = busstops %>% na.omit
coords = coords %>% na.omit
busstops.sp = SpatialPointsDataFrame(coords, data = data.frame(busstops$name, busstops$id), proj4string = CRS(ukgrid))

busstops.sp.ll <- spTransform(busstops.sp, CRS(latlong))
colnames(busstops.sp.ll@coords) = c("long", "lat")

# load boroughs shapefiles
london.shp = readOGR("./borough/", "London_Borough_Excluding_MHW")
london.shp = spTransform(london.shp, CRS(latlong))
# run ingress snippet (might fire back!) for id'ing in which shape what lies
stops.by.borough = over(london.shp, busstops.sp.ll, returnList = TRUE)
borough.list = c("Kingston", "Croydon", "Bromley", "Hounslow", "Ealing", 
                 "Havering", "Hillingdon", "Harrow", "Brent", "Barnet", "Lambeth",
                 "Southwark", "Lewisham", "Greenwich", "Bexley", "Enfield", "Waltham Forest",
                 "Redbridge", "Sutton", "Richmond", "Merton", "Wandsworth", "Hammersmith and Fulham",
                 "Kensington & Chelsea", "Westminster", "Kamden", "Tower Hamlets", "Hackney",
                 "Islington", "Haringey", "Newham", "Barking", "City")
n.of.stops = as.numeric()
for (i in 1:length(stops.by.borough)) {
  n.of.stops[i] = stops.by.borough[[i]] %>% nrow
}
# get n of stations for each ward