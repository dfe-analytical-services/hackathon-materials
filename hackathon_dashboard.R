
library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)
library(shinydashboard)

# Load data
df <- read_csv("data/Pre-Stats Awayday Hackathon!(Sheet1).csv") %>% 
  dplyr::distinct() %>% 
  #isolate date from completion time column
  dplyr::mutate(time_stamp = lubridate::mdy_hm(`Completion time`)) %>%
  #if there is a submission by someone with the same first and last name, take the latest response only
  dplyr::group_by(`First name`, `Last name`) %>%
  dplyr::slice_max(order_by = time_stamp, n = 1) %>% 
  #ungroup
  dplyr::ungroup()

# df %>%
#   separate_rows(`Which is your preferred location(s) for the hackathon if it was to happen in person/hybrid? Select all that apply.`, sep = ";") %>%
#   #filter out blank responses
#   filter(`Which is your preferred location(s) for the hackathon if it was to happen in person/hybrid? Select all that apply.`!="") %>%
#   dplyr::count(`Which is your preferred location(s) for the hackathon if it was to happen in person/hybrid? Select all that apply.`) %>%
#   mutate(per = n / sum(n) * 100)

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Hackathon Survey Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Format & Timing", tabName = "format", icon = icon("calendar-alt")),
      menuItem("Location Preferences", tabName = "location", icon = icon("map-marker-alt")),
      menuItem("Topic Interests", tabName = "topics", icon = icon("list")),
      menuItem("Skill Levels", tabName = "skills", icon = icon("chart-bar")),
      menuItem("Git Experience", tabName = "git", icon = icon("code-branch")),
      menuItem("Support Needs", tabName = "support", icon = icon("hands-helping"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "overview",
              fluidRow(
                box(title = "Total Responses", width = 4, status = "primary", solidHeader = TRUE,
                    h3(nrow(df))),
                box(title = "Participation Interest", width = 8, status = "primary", solidHeader = TRUE,
                    plotOutput("participationPlot", height = "700px"))
              )
      ),
      tabItem(tabName = "format",
              fluidRow(
                box(title = "Preferred Schedule - numbers for each option", width = 6, plotOutput("schedulePlot")),
                box(title = "Preferred Schedule - numbers for each option and both", width = 6, plotOutput("schedulePlot2")),
                box(title = "Preferred Format", width = 6, plotOutput("formatPlot"))
              )
      ),
      tabItem(tabName = "location",
              fluidRow(
                box(title = "Preferred Locations", width = 12, plotOutput("locationPlot", height = "900px"))
              )
      ),
      tabItem(tabName = "topics",
              fluidRow(
                box(title = "Topic Preferences", width = 12, plotOutput("topicPlot", height = "900px"))
              )
      ),
      tabItem(tabName = "skills",
              fluidRow(
                box(title = "Skill Levels", width = 12, plotOutput("skillPlot", height = "1000px"))
              )
      ),
      tabItem(tabName = "git",
              fluidRow(
                box(title = "Git Experience", width = 12, plotOutput("gitPlot", height = "1000px"))
              )
      ),
      tabItem(tabName = "support",
              fluidRow(
                box(title = "Support Needs (Before)", width = 6, tableOutput("supportBefore")),
                box(title = "Support Needs (During)", width = 6, tableOutput("supportDuring"))
              )
      )
    )
  )
)

# Server
server <- function(input, output) {
  
  output$participationPlot <- renderPlot({
    df %>% 
      dplyr::count(`Are you interested in participating in an upcoming hackathon?\n`) %>%
      #remove string after the - from the column
      dplyr::mutate(`Are you interested in participating in an upcoming hackathon?\n` = sub(" -.*", "", `Are you interested in participating in an upcoming hackathon?\n`)) %>%
      #convert to percentages
      mutate(per = n / sum(n) * 100) %>%
      ggplot( aes(fill = `Are you interested in participating in an upcoming hackathon?\n`
                  ,x = `Are you interested in participating in an upcoming hackathon?\n`
                  , y = per)) +
      geom_bar(stat = "identity") +
      #add percentage labels
      geom_text(aes(label = paste0(n,"(",round(per, 1), "%)")), position = position_stack(vjust = 0.5), size = 6, colour = "white") +
      #remove legend
      
      
      labs(x = "Participation Interest", y = "%")+
      coord_flip() +
      afcharts::theme_af()+
      afcharts::scale_fill_discrete_af()+
      theme(legend.position = "none") 
  })
  
  output$schedulePlot <- renderPlot({
    df %>%
      separate_rows(`Would you rather the hackathon take part over 2 full/dedicated consecutive days, or spread out more flexibly over a whole week? Select all that apply.`, sep = ";") %>%
      #filter out blank responses
      filter(`Would you rather the hackathon take part over 2 full/dedicated consecutive days, or spread out more flexibly over a whole week? Select all that apply.`!="") %>%
      dplyr::count(`Would you rather the hackathon take part over 2 full/dedicated consecutive days, or spread out more flexibly over a whole week? Select all that apply.`) %>%
      mutate(per = n / sum(n) * 100) %>%
      ggplot(aes(fill = `Would you rather the hackathon take part over 2 full/dedicated consecutive days, or spread out more flexibly over a whole week? Select all that apply.`
                 ,x = `Would you rather the hackathon take part over 2 full/dedicated consecutive days, or spread out more flexibly over a whole week? Select all that apply.`
                 , y = per)) +
      geom_bar(stat = "identity") +
      
      #add percentage labels
      geom_text(aes(label = paste0(n,"(",round(per, 1), "%)")), position = position_stack(vjust = 0.5), size = 6, colour = "white") +
      
      labs(x = "Preferred Schedule", y = "%")+
      afcharts::theme_af()+
      afcharts::scale_fill_discrete_af()+
      theme(legend.position = "none") 
  })
  
  
  #sch plot 2
  
  
  output$schedulePlot2 <- renderPlot({
    df %>%
      dplyr::mutate(sch_flag = dplyr::if_else(stringr::str_detect(`Would you rather the hackathon take part over 2 full/dedicated consecutive days, or spread out more flexibly over a whole week? Select all that apply.`,
                                                                  ";"),
                                              "Both",
                                              `Would you rather the hackathon take part over 2 full/dedicated consecutive days, or spread out more flexibly over a whole week? Select all that apply.`)) %>% 
      dplyr::count(sch_flag) %>% 
      mutate(per = n / sum(n) * 100) %>%
      ggplot(aes(fill = sch_flag
                 ,x = sch_flag
                 , y = per)) +
      geom_bar(stat = "identity") +
      
      #add percentage labels
      geom_text(aes(label = paste0(n,"(",round(per, 1), "%)")), position = position_stack(vjust = 0.5), size = 6, colour = "white") +
      
      labs(x = "Preferred Schedule", y = "%")+
      afcharts::theme_af()+
      afcharts::scale_fill_discrete_af()+
      theme(legend.position = "none") 
  })
  output$formatPlot <- renderPlot({
    df %>%
      separate_rows(`What format would you prefer for the hackathon? Select all that apply.`, sep = ";") %>%
      #filter out blank responses
      filter(`What format would you prefer for the hackathon? Select all that apply.`!="") %>%
      dplyr::count(`What format would you prefer for the hackathon? Select all that apply.`) %>%
      mutate(per = n / sum(n) * 100) %>%
      ggplot(aes(fill = `What format would you prefer for the hackathon? Select all that apply.`,
                 x = `What format would you prefer for the hackathon? Select all that apply.`,
                 y=per)) +
      geom_bar(stat = 'identity') +
      #add percentage labels
      geom_text(aes(label = paste0(n,"(",round(per, 1), "%)")), position = position_stack(vjust = 0.5), size = 6, colour = "white") +
      labs(x = "Preferred Format", y = "%")+
      afcharts::theme_af()+
      afcharts::scale_fill_discrete_af()+
      theme(legend.position = "none") 
  })
  
  output$locationPlot <- renderPlot({
    df %>%
      separate_rows(`Which is your preferred location(s) for the hackathon if it was to happen in person/hybrid? Select all that apply.`, sep = ";") %>%
      #filter out blank responses
      filter(`Which is your preferred location(s) for the hackathon if it was to happen in person/hybrid? Select all that apply.`!="") %>%
      dplyr::count(`Which is your preferred location(s) for the hackathon if it was to happen in person/hybrid? Select all that apply.`) %>%
      mutate(per = n / sum(n) * 100) %>%
      ggplot(aes(fill = `Which is your preferred location(s) for the hackathon if it was to happen in person/hybrid? Select all that apply.`,
                 x = `Which is your preferred location(s) for the hackathon if it was to happen in person/hybrid? Select all that apply.`,
                 y= per)) +
      geom_bar(stat = "identity") +
     
      #add percentage labels
      geom_text(aes(label = paste0(n,"(",round(per, 1), "%)")), position = position_stack(vjust = 0.5), size = 6, colour = "white") +
      
      labs(x = "Location", y = "%")+
      
      afcharts::theme_af()+
      theme(legend.position = "none") 
  })
  
  output$topicPlot <- renderPlot({
    df %>%
      dplyr::rename(topics = `This is a list of topics that may be covered in the hackathon projects. Please rank them according to how likely you are to pick them.`) %>%
      tidyr::separate(col = topics,
                      into = paste0("project_", 1:10), sep = ";", fill = "right") %>% 
      dplyr::count(project_1) %>% 
      mutate(per = n / sum(n) * 100) %>%
      ggplot(aes(fill = project_1,
                 x = project_1,
                 y = per)) +
      geom_bar(stat="identity") +
      #add percentage labels
      geom_text(aes(label = paste0(n,"(",round(per, 1), "%)")), position = position_stack(vjust = 0.5), size = 6, colour = "black") +
      
      labs(x = "First choice topic", y = "%")+
      afcharts::theme_af()+
      theme(legend.position = "none") 
  })
  
  output$skillPlot <- renderPlot({
    skill_cols <- c("Which of these best describes your skill level when working with data and algorithms?",
                    "Which of these best describes your skill level when working with AI and LLMs?",
                    "Which of these best describes your skill level when working with Software & Engineering?",
                    "Which of these best describes your skill level when working with R & Python Coding?")
    df %>%
      select(all_of(skill_cols)) %>%
      pivot_longer(cols = everything(), names_to = "Skill", values_to = "Level") %>%
      dplyr::filter(!is.na(Level)) %>%
      #change Level so all string after the number is removed
      dplyr::mutate(Level = sub(".*?([0-9]+).*", "\\1", Level)) %>%
      #replace 1 with no experience and 5 with high experience
      dplyr::mutate(Level = factor(Level, levels = c("1", "2", "3", "4", "5"),
                                   labels = c("No Experience", "Beginner", "Intermediate", "Advanced", "Expert"))) %>%
      dplyr::count(Skill,Level) %>% 
      mutate(per = n / sum(n) * 100) %>%
      ggplot(aes(fill = Level,
                 x = Level,
                 y=per)) +
      geom_bar(stat = "identity") +
      #add percentage labels
      geom_text(aes(label = paste0(n,"(",round(per, 1), "%)")), position = position_stack(vjust = 0.5), size = 6, colour = "black") +
      #flip axis for better readability
      coord_flip() +
      facet_wrap(~Skill, scales = "free_x") +
      labs(x = "Skill Level", y = "%")+
      afcharts::theme_af()+
      # afcharts::scale_fill_discrete_af()+
      theme(legend.position = "none") 
  })
  
  output$gitPlot <- renderPlot({
    df %>%
      select(starts_with("Please rate your experience with Git.")) %>%
      pivot_longer(cols = everything(), names_to = "GitSkill", values_to = "Level") %>%
      #remove please rate your experience with git as a string from gitskill
      dplyr::mutate(GitSkill = sub("Please rate your experience with Git\\.", "", GitSkill)) %>%
      #factor the Level column so the order is no experience, minimal, some, working and then expert
      dplyr::mutate(Level = factor(Level,
                                   levels = c("No experience",
                                              "Minimal experience - Some knowledge but no application",
                                              "Some experience - Some application of this skill but not consistent",
                                              "Working experience - Frequent application of this skill",
                                              "Expert - Applies this skill almost daily and able to assist others"))) %>%
      dplyr::count(GitSkill,Level) %>% 
      mutate(per = n / sum(n) * 100) %>%
      ggplot(aes(fill = Level,
                 x = Level,
                 y=per)) +
      geom_bar(stat = "identity") +
      #add percentage labels
      geom_text(aes(label = paste0(n,"(",round(per, 1), "%)")), position = position_stack(vjust = 0.5), size = 6, colour = "black") +
      #flip axis for better readability
      coord_flip() +
      facet_wrap(~GitSkill, scales = "free_x") +
      labs(x = "Git Experience Level", y = "%")+
      afcharts::theme_af()+
     # afcharts::scale_fill_discrete_af()+
      theme(legend.position = "none") 
  })
  
  output$supportBefore <- renderTable({
    df %>%
      select(`What kind of support would you want BEFORE the hackathon to make it work for you?`) %>%
      filter(!is.na(`What kind of support would you want BEFORE the hackathon to make it work for you?`))
  })
  
  output$supportDuring <- renderTable({
    df %>%
      select(`What kind of support would you want DURING the hackathon to make it work for you?`) %>%
      filter(!is.na(`What kind of support would you want DURING the hackathon to make it work for you?`))
  })
}

# Run the app
shinyApp(ui, server)
