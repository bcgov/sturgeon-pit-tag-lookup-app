# HEAD --------------------------------------------------------------------

#' Authors: Sima Usvyatsov, Golder Associates, Ltd for MLNFORD - 13 May 2021
#'          Sarah Stephenson, BC Gov
#' Maintainer: Sarah Popov, BC Gov
#' 
#' This app visualizes telemetry data from white sturgeon caught in the 
#' Fraser River basin 1991-2020. 

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

# UI ----------------------------------------------------------------------

library(plyr)
library(dplyr)
library(tidyr)

library(writexl)

library(shiny)
library(shinydashboard)

library(DT)
# library(shinycssloaders)
# library(shinyWidgets)

# this is the spinner used in the group animation panel while the animation is loading
options(spinner.type=1) 

# this code contains all the components of the user interface used in this app:
# user interface, allowing the user to filter data by PIT tag

# define the user interface function									   			
fluidPage(title = "Fraser River drainage White Sturgeon PIT tag lookup tool",
          theme = "bcgov.css",
          
	titlePanel(
	  # App title
	  fluidRow(column(12, "Fraser River drainage White Sturgeon PIT tag lookup"))), 
	
	  # Info box + map
	fluidRow(
 		  # Left-side info sidebar
 		  column(5, 
 		         # Image w caption
 		         div(class = "figure",
 		             img(width = '100%', src = "P8240101.JPG", alt = "A juvenile sturgeon held up by somebody's arm. In the background is a lake with mountains and a clear sky."),
 		             div(class = "caption", 
 		                 HTML("Photo credit - Ministry of Forests"))),
 		                
				h5(HTML("This app displays White Sturgeon (<i>Acipenser transmontanus</i>) mark-recapture data collected in the Fraser River drainage from May 1991 to December 2020.",
				        " With this tool, any user can enter in a PIT tag serial number to look up if the fish has been recaptured before and any associated data (fish length, location, etc. at last capture).
				        <br/>
				        <br>
				        See below for further information and disclaimer. 
				        <br>")),
				
				div(
				  textInput(inputId = "TagID", 
				            label = "Enter an individual PIT tag number:", 
				            value = "7F7B0C4E1D")
				  ) # close div
				
				), # close column
				
				), # close fluidRow
				
	# Data table
	fluidRow(
				# user-provided tag IDs
				# div(textInput(inputId = "TagID", label = "Enter an individual PIT tag number", 
						# value = "7F7B0C4E1D"), style = "padding: 25px;margin-left: 10px;margin-right: 10px;margin-top: -200px"),
				# div(DT::dataTableOutput("TagTable"), style = "font-size:80%;padding-top:-5px; padding-bottom:2px;margin-left:20px;margin-right:20px;margin-top:-50px")))
				
				div(DT::dataTableOutput("TagTable"), style = "font-size:80%;padding-top:5px; padding-bottom:2px;margin-left:20px;margin-right:20px;margin-top:5px")
				),
	
	# About + Disclaimer
	fluidRow(
	  column(width = 12,
	         style = "padding: 1em;",
	  HTML("<h2>About</h2>
	  These data are maintained by the Reconciliation, Lands, Policy and Data Division within the <a href = 'https://www2.gov.bc.ca/gov/content/environment/plants-animals-ecosystems/fish/fish-and-fish-habitat-data-information'>Ministry of Water, Land and Resource Stewardship (WLRS)</a>. This database is currently under maintenance while we update records to 2026. Data and information housed within the database is collected by both government biologists and partners such as First Nations, scientific fish collection permit holders, and participating fishery organizations.
	    <br/>
	    <br/>
	  <h2>Disclaimer</h2>
	    Data displayed by this app should be used with caution as it may not be verified and can change as new data become available. This app is not intended to provide authoritative knowledge, but rather provide a platform to facilitate data sharing and inform the public about White Sturgeon, aquatic wildlife, and watersheds in general.
	  <br/>
	  <br/>
	    Users of this app will save harmless and forever releases and discharges the Province of British Columbia from and against any and all claims, demands, damages, causes of action, losses, costs and expenses of any kind and every nature which can or may arise from, or by reason of any act in relation to or arising from, the data provided in this app.
	  <br/>
	  <br/>
	    For specific questions and feedback related to this app, or the provincial White Sturgeon mark-recapture database, please email <a href = 'mailto:Fish.Issues@gov.bc.ca?subject=Sturgeon PIT tag lookup tool inquiry'>Fish.Issues@gov.bc.ca</a>.")
	)
	),
	
	# Footer
	fluidRow(
	  column(width = 12,
	       style = "padding: 0; background-color:#003366; border-top:2px solid #fcba19;",
	       tags$footer(id = "footer",
	                   tags$div(class="container", 
	                            style="width: 100%; padding: 0; display:flex; justify-content:space-around; flex-direction: row; text-align:center; align-items: center; height:46px;",
	                            img(src = "gov3_bc_logo.png", style = "width: 134px; height: 45px;"),
	                            tags$ul(style="padding: 0; display:flex; flex-direction:row; flex-wrap:wrap; margin:0; list-style:none; align-items:center; height:100%;",
	                                    tags$li(a(href="https://www2.gov.bc.ca/gov/content/home", 
	                                              "Home")),
	                                    tags$li(a(href="https://www2.gov.bc.ca/gov/content/home/disclaimer", 
	                                              "Disclaimer")),
	                                    tags$li(a(href="https://www2.gov.bc.ca/gov/content/home/privacy", 
	                                              "Privacy")),
	                                    tags$li(a(href="https://www2.gov.bc.ca/gov/content/home/accessibility", 
	                                              "Accessibility")),
	                                    tags$li(a(href="https://www2.gov.bc.ca/gov/content/home/copyright", 
	                                              "Copyright")),
	                                    tags$li(a(href="https://www2.gov.bc.ca/StaticWebResources/static/gov3/html/contact-us.html", 
	                                              "Contact",
	                                              style = "border: none;"))
	                                    ) # close ul
	                            ), # close ul container div
	                   ) # close footer 
	       ) # close footer column
	) # close footer fluidRow
	
	) # close fluidPage
	
	
	