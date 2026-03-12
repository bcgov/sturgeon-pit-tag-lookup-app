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

library(shiny)
library(shinydashboard)

# read in the fish data				
data <- read.csv("dat.csv",
                 check.names = FALSE,
                 na.strings = c("NA", ""),
                 strip.white = TRUE) %>%
		rename(`River kilometer area` = RKM_Round) %>%
  dplyr::arrange(`Capture date`)

# Shiny server function - this contains handling all the user inputs, and runs 
# all the calculations and output entities (like tables, plots, and maps), as well as producing user-friendly warnings
function(input, output, session) {

	# to create a list of serial tag numbers, from user input
	RetrieveIndividualTags <- reactive({
					tags <- gsub(" ", "", input$TagID)
					tags <- trimws(unlist(strsplit(tags, ",")))
					id <- which(data$`Tag number` %in% toupper(tags))
					
					# If no ID supplied, return full data table
					if (is.integer(id) && length(id) == 0) {
					  out <- data #%>%
					    #select(-FishID)
					} else { # Else return subset
					  out <- data %>%
					    filter(FishID %in% unique(data[id,]$FishID)) #%>%
					    #select(-FishID)
					}
					
					return(out)
					})
			
	output$TagTable <- DT::renderDataTable({
		RetrieveIndividualTags()
								   }, 
		options = list(autoWidth = FALSE, 
		               pageLength = 5,
		               #paging = FALSE, 
		               searching = FALSE))
	
	# download handler for the tabular summaries
	output$DownloadTagTable <- downloadHandler(
	  filename = "white-sturgeon-pit-records.csv",
	  content = function(filename){
	    # Option A: download filtered data
	    out <- list("tag info" = RetrieveIndividualTags(),
	                "User inputs" = data.frame(`Tag number` = input$TagID))
	    # Option B: download all data
	    # out <- data
	    write.csv(out, filename) # write to csv - this will show in the user's downloads
	    } # content
	)  # DownloadTagTable
								   
}



