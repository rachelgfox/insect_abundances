suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(rgdal))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(rvest))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(maps))
suppressPackageStartupMessages(library(ggmap))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(RColorBrewer))


insects<- read.csv("./Data/insectcounts_na.csv", header=TRUE) %>%
          tbl_df() %>%
          gather(family,n, 4:67) %>%
          mutate(date=mdy(date)) %>%
          transmute(date,bottle.name,family,n)
          
          

##MAPPING

jr.shapefile <- readOGR(dsn="./Data/JR_TRAILS", layer="JR_TRAILS", verbose=FALSE) %>%
  spTransform(CRS("+proj=longlat +ellps=WGS84")) 

ww.data <- ww.shapefile@data %>% tbl_df() 
ww.map <- fortify(ww.shapefile, region="FIPS")