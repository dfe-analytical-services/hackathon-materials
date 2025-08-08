library(dplyr)
# read in data ------------------------------------------------------------

hack_proj_data <- data.table::fread("data/welcome_guide_Hackathon_Project_Proposal_Form.csv") %>% 
  #pivot the data longer 
  tidyr::pivot_longer(
    cols = -c(1), 
    names_to = "project", 
    values_to = "answer"
  ) 


for ( i in unique(hack_proj_data$project)) {
 params <- list(
   #get project name
   proj_name = i,
   #get project description
   proj_desc = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "What problem does your project aim to solve?") %>% 
     dplyr::pull(answer),
   #get why it's important
   proj_important = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "Why is this problem important or interesting to explore?") %>% 
     dplyr::pull(answer),
   proj_solution = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "What kind of solution or outcome do you envision?") %>% 
     dplyr::pull(answer),
   proj_data_1 = hack_proj_data %>%
     dplyr::filter(project == i & Qualifiers == "What data will participants need to use?") %>% 
     dplyr::pull(answer),
   proj_data_2 = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "Is this data already available, or will it need to be created or simulated?") %>% 
     dplyr::pull(answer),
   proj_code = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "Do participants need access to existing code to take part in this project? If yes, please provide detail of where this code is and how the participants can access it") %>% 
     dplyr::pull(answer),
   proj_tools = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "Are there any tools, platforms, or programming languages you expect participants to use?") %>% 
     dplyr::pull(answer),
   proj_know = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "Will a subject matter expert be available during the hackathon to answer questions about the topic or data? If yes, please provide their name and availability.") %>% 
     dplyr::pull(answer),
   proj_real = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "What do you think a team could realistically achieve in 2 days or 1 week?") %>% 
     dplyr::pull(answer),
   proj_chall= hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "Are there any known challenges or limitations participants should be aware of?") %>% 
     dplyr::pull(answer),
   proj_info=  hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "Is there anything else you'd like us to know about your project idea?") %>% 
     dplyr::pull(answer),
   proj_datacamp= hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "DataCamp courses") %>% 
     dplyr::pull(answer),
   proj_other_resources = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "Other resources") %>% 
     dplyr::pull(answer),
   proj_skills = hack_proj_data %>% 
     dplyr::filter(project == i & Qualifiers == "What skills would be helpful for participants to have (e.g. data science, software engineering, domain knowledge)?") %>% 
     dplyr::pull(answer)
  
   
 )
 
 # Create output file name
 output_file <- paste0(gsub("[^a-zA-Z0-9_]", "_", i), ".html")


 # Render the Quarto document
 quarto::quarto_render(
   input = "participant_pack.qmd",
   execute_params = params,
   output_file = output_file
 )
 
 # Define source and destination paths
 source_path <- file.path(output_file)
 destination_path <- file.path("participant_packs", output_file)
 
 # Move the file
 file.rename(source_path, destination_path)
}



