library(shiny)
library(tidyverse)
library(DT)

# Load data
data <- read.csv("data/Pre-Stats Awayday Hackathon!(Sheet1).csv", stringsAsFactors = FALSE) %>% 
  
  tidyr::separate(col = `This.is.a.list.of.topics.that.may.be.covered.in.the.hackathon.projects..Please.rank.them.according.to.how.likely.you.are.to.pick.them.`,
                  into = paste0("project_", 1:10), sep = ";", fill = "right")

#clean data

select_that_apply_questions <- data %>% 
  #remove duplicates
  dplyr::distinct() %>%
  #get info from the 9th col (participant column)
  dplyr::mutate(attendance_type = dplyr::case_when( stringr::str_detect(Are.you.interested.in.participating.in.an.upcoming.hackathon.., "part" ) ~ "particpant",
                                                    stringr::str_detect(Are.you.interested.in.participating.in.an.upcoming.hackathon.., "volun") ~ "volunteer",
                                                    stringr::str_detect(Are.you.interested.in.participating.in.an.upcoming.hackathon..,"Maybe") ~ "maybe",
                                                    TRUE ~ "no")) %>%
  
  #create flag for consective days
  dplyr::mutate(consecutive_days = dplyr::if_else(
   stringr::str_detect(Would.you.rather.the.hackathon.take.part.over.2.full.dedicated.consecutive.days..or.spread.out.more.flexibly.over.a.whole.week..Select.all.that.apply.,
                       "consecutive"
                       ),1,0
  ),
  spread_over_week = dplyr::if_else(
    stringr::str_detect(Would.you.rather.the.hackathon.take.part.over.2.full.dedicated.consecutive.days..or.spread.out.more.flexibly.over.a.whole.week..Select.all.that.apply.,
                        "whole week"),1,0
  )) %>% 
  tidyr::separate_rows(c(`Select.the.days.that.would.best.fit.your.availability..Select.all.that.apply.`
                         
                         ),sep=";") %>% 
  tidyr::separate_rows(c(
                         `Would.you.rather.the.hackathon.take.part.over.2.full.dedicated.consecutive.days..or.spread.out.more.flexibly.over.a.whole.week..Select.all.that.apply.`
  ),sep=";")

  