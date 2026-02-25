# HEAD --------------------------------------------------------------------

#' Authors: Sima Usvyatsov, Golder Associates, Ltd for MLNFORD - 13 May 2021
#'          Sarah Stephenson, BC Gov
#' Maintainer: Sarah Popov, BC Gov
#' 
#' This app visualizes telemetry data from white sturgeon caught in the 
#' Fraser River basin 1991-present. 

# LICENSE -----------------------------------------------------------------

#' Copyright 2026 Province of British Columbia
#' 
#' Licensed under the Apache License, Version 2.0 (the "License");
#' you may not use this file except in compliance with the License.
#' You may obtain a copy of the License at
#' 
#' http://www.apache.org/licenses/LICENSE-2.0
#' 
#' Unless required by applicable law or agreed to in writing, software
#' distributed under the License is distributed on an "AS IS" BASIS,
#' WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#' See the License for the specific language governing permissions and
#' limitations under the License.

# SERVER ------------------------------------------------------------------

library(plyr)
library(dplyr)
library(tidyr)

library(writexl)

library(shiny)
library(shinydashboard)
library(leaflet)
library(leaflet.extras)

# read in the fish data				
data <- readRDS("compiled data.rds") %>%
		rename(`River kilometer area` = RKM_Round)

# Shiny server function - this contains handling all the user inputs, and runs 
# all the calculations and output entities (like tables, plots, and maps), as well as producing user-friendly warnings
function(input, output, session) {
  
#------------------------------------------------------ Individual tag animation --------------------------------------------
	# to create a list of serial tag numbers, from user input
	RetrieveIndividualTags <- reactive({
					tags <- gsub(" ", "", input$TagID)
					tags <- trimws(unlist(strsplit(tags, ",")))
					id <- which(data$`Tag number` %in% toupper(tags))
					
					data %>%
						filter(FishID %in% unique(data[id,]$FishID)) %>%
						select(-FishID)
										})
												
	# download handler for the tabular summaries
	# output$RetrieveIndividualTagsDownload <- downloadHandler(
		# filename = "List of tag encounters.xlsx",
							
		# content = function(filename){
			# out <- list("tag info" = RetrieveIndividualTags(),
						# "User inputs" = data.frame(`Tag number` = input$TagID))
									
			# write_xlsx(out, filename) # write to excel - this will show in the user's downloads
					# } # content
					# )  # RetrieveIndividualTagsDownload
			
	output$TagTable <- DT::renderDataTable({
		RetrieveIndividualTags() %>%
			select(-Lat, -Lon, -`River km`)
								   }, options = list(autoWidth = FALSE, paging = FALSE, searching = FALSE))

	output$Map <- renderLeaflet({
		leaflet(data %>% filter(!is.na(Lon), !is.na(Lat)), 
			options = leafletOptions(
			attributionControl=FALSE, minZoom = 4, maxZoom = 11)) %>%
			setView(lng = -123.6, lat = 51.2, zoom = 6) %>%
			addProviderTiles("Esri.WorldImagery", layerId = "basetile",
				options = providerTileOptions(opacity = 0.75)) %>% 
			#setMaxBounds(lng1 = -122, lat1 = 47, lng2 = -118, lat2 = 56) %>%
	    addFullscreenControl() # leaflet.extras
										}) # Map
								   
	observe({
		if(input$TagID != "All" & nrow(RetrieveIndividualTags() %>% filter(!is.na(Lon), !is.na(Lat))) == 0){
			leafletProxy("Map") %>% 
					clearShapes()	
												}	
					 
		if(input$TagID != "All" & nrow(RetrieveIndividualTags() %>% filter(!is.na(Lon), !is.na(Lat))) > 0){
			dat <- RetrieveIndividualTags() %>%
					filter(!is.na(Lon), !is.na(Lat)) %>%
					mutate(Lab = paste0("Tag number ", `Tag number`, "<br/>",
										"Capture date = ", `Capture date`, "<br/>",
										"River kilometer area = ", `River kilometer area`, "<br/>",
										"Fork length = ", `Fork length`, " cm"))
			leafletProxy("Map") %>% 
					addCircles(data = dat, lng = dat$Lon, lat = dat$Lat, 
						radius = 5000, opacity = 0.7, fill = TRUE, fillOpacity = 0.7,
						color = "red", fillColor = "white", weight = 1, popup = ~as.character(Lab)) 
												}
												
		if(input$TagID == "All"){
			dat <- data %>%
					filter(!is.na(Lon), !is.na(Lat)) %>%
					mutate(Lab = paste0("Tag number ", `Tag number`, "<br/>",
										"Capture date = ", `Capture date`, "<br/>",
										"River kilometer area = ", `River kilometer area`, "<br/>",
										"Fork length = ", `Fork length`, " cm"))
			leafletProxy("Map") %>% 
					addCircles(data = dat, lng = dat$Lon, lat = dat$Lat, 
						radius = 5000, opacity = 0.7, fill = TRUE, fillOpacity = 0.7,
						color = "red", fillColor = "white", weight = 1, popup = ~as.character(Lab)) 
												}	
												
										}) # Map	
								   
}



