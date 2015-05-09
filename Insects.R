suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(rgdal))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(rvest))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(maps))
suppressPackageStartupMessages(library(ggmap))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(RColorBrewer))

#Cleaning
insects<- read.csv("./Data/insectcounts_na.csv", header=TRUE) %>%
          tbl_df() %>%
          gather(family,n, 4:67) %>%
          mutate(date=mdy(date)) %>%
          transmute(date,bottle.name,family,n)
                    
#Extracting data and creating data for plotting

##Trails

jr.trailsfile <- readOGR(dsn="./Data/JR_TRAILS", layer="JR_TRAILS", verbose=FALSE) %>%
  spTransform(CRS("+proj=longlat +ellps=WGS84")) 
trails.map <- fortify(jr.trailsfile)
trail.data <-jr.trailsfile@data %>% tbl_df()

##Vegetation
jr.vegfile <- readOGR(dsn="./Data/JRVEG_SHAPEFILE", layer="JR_vegetation_2012", verbose=FALSE) %>%
  spTransform(CRS("+proj=longlat +ellps=WGS84")) 

jr.vegfile@data$id = rownames(jr.vegfile@data)

veg.map <- fortify(jr.vegfile, region="id") %>% tbl_df()
veg.df <- inner_join(veg.map, jr.vegfile@data, by="id") %>%
          filter(CNDDB1 %in% c("Bog and Marsh", "Broad Leafed Upland Tree Dominated", "Coniferous Upland Forest and Woodland", "Grass and Herb Dominated Communities", "Riparian and Bottomland Habitat", "Scrub and Chaparral"))

#Overall Map
#google map access
google.map <-
  get_map(location = "Searsville Lake, San Mateo County, CA", maptype = "roadmap", zoom = 16, color = "color")

#trails and veg + google map context
ggmap(google.map)+
  geom_polygon(data=veg.df, aes(x=long, y=lat, group=group, fill=CNDDB1),alpha=0.5) +
  geom_path(data=trails.map, aes(x=long, y=lat, group=group),col="black", size=0.2) +
  coord_map() +
  theme_bw()+
  coord_cartesian(xlim=c(-122.245, -122.230), ylim=c(37.401, 37.410))
