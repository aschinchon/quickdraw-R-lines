# Load in libraries
library(data.table)
library(plyr)
library(dplyr)
library(rjson)
library(ggplot2)
library(purrr)
library(broom)
library(ISOcodes)
library(xkcd)

# This funcion divides json into columns to create a data frame
# also filters drawings to remove those with more than 1 line
parse_drawing = function(list)
{
  if (length(list$drawing)==1) 
  {data.table(x=list$drawing[[1]][[1]], 
              y=list$drawing[[1]][[2]], 
              country=list$countrycode)}
}

# Read ndjson dataset
ndjson=readLines("data/line.ndjson")

# Parse data with parse_drawing function
lapply(ndjson, function(x) {fromJSON(x) %>% 
    parse_drawing }) %>% 
  rbindlist(idcol="id") -> dt_lines

# Add country name with ISO_3166_1 dataset from ISOcodes package
# also count how many distinct drawings by country
dt_lines %>% inner_join(ISO_3166_1, by=c("country"="Alpha_2")) %>% 
  group_by(country, Name) %>% 
  summarize(drawings=n_distinct(id)) %>% 
  arrange(-drawings) -> stats

# Keep countries with more than 150 drawings
countries <-  stats %>% filter(drawings>150)

# This loop obtain data to create plots for each country
results <- data.frame()
for (i in 1:nrow(countries))
{
  # Filter data of the country
  dt_lines %>% filter(country==countries$country[i]) -> sub_lines
  
  # Calculate linear regression and keep slope parameters
  sub_lines %>%
    split(.$id) %>%
    map(~tidy(lm(y ~ x, data = .))) %>%
    bind_rows(.id="id") %>% 
    filter(term=="x")-> params
  
  # Calculate direction of the line
  sub_lines %>% 
    split(.$id) %>% 
    lapply(function(df) {df %>% group_by(id) %>% summarize(diff= last(x)-first(x))}) %>% 
    bind_rows() -> adjust
  
  # Divide the circle in sections of 2*step degrees and summarize the amount of lines
  # within each section
  step=15
  params %>% 
    mutate(id=as.numeric(id)) %>% 
    inner_join(adjust, by="id") %>% 
    mutate(rad=atan(estimate)+(diff<0)*pi) %>% 
    mutate(deg=(rad * 180) / (pi)) %>% 
    mutate(deg = ifelse(deg<0, 360+deg, deg)) %>% 
    mutate(angulo=cut(deg, seq(from=0, to=360, by=step), include.lowest = TRUE, labels=FALSE)) %>% 
    mutate(angulo = (floor(as.numeric(angulo)/2)*(2*step)) %% 360) %>% 
    group_by(angulo) %>% 
    summarize(size=n()) %>% 
    arrange(angulo) -> df

  # Calculate relative frequency by section  
  data.frame(country=countries$country[i], angulo=seq(0,350,2*step)) %>% 
    left_join(df, by="angulo") %>%  
    mutate(size=ifelse(is.na(size),0,size)) %>% 
    mutate(size_p=size/sum(size))-> df
  
  df %>% rbind(results) -> results  
  
}

# Since previous step takes a long time, you may want to save results 
# saveRDS(results, "results.RDS")

# Top 4 countries with most % of horizontal left to right lines
results %>% filter(angulo==0) %>% arrange(-size_p) %>% head(4)
# Top 4 countries with most % of vertical bottom up lines
results %>% filter(angulo==90) %>% arrange(-size_p) %>% head(4)
# Top 4 countries with most % of horizontal right to left lines
results %>% filter(angulo==180) %>% arrange(-size_p) %>% head(4)
# Top 4 countries with most % of vertical up bottom lines
results %>% filter(angulo==270) %>% arrange(-size_p) %>% head(4)
# Top 4 countries with most % of oblique lines
results %>% 
  filter(!(angulo %in% c(0,90,180,270))) %>% 
  group_by(country) %>% 
  summarize(total=sum(size_p)) %>% arrange(-total) %>% head(4)

# Pick a country to plot
country_to_plot="HU"
# Filter results
results %>% filter(country==country_to_plot) -> df
# Do the plot
ggplot(df) + 
  geom_bar(stat="identity",
           fill="yellow",
           colour="black",
           width=1,
           aes(x = as.factor(angulo), y = size_p)) + 
  geom_vline(xintercept = c(1,4,7,10), colour = "gray80", lwd=.2) +
  geom_vline(xintercept = 2.5, colour = "gray80", lwd=.2) +
  annotate("text",x=2.5,y=seq(from=max(df$size_p)/3, length.out = 3, by=max(df$size_p)/3), 
           label = sprintf("%1.2f", seq(from=max(df$size_p)/3, length.out = 3, by=max(df$size_p)/3)),
           family="xkcd",
           vjust=-.4, hjust=0, 
           colour = "gray60") +
  geom_hline(yintercept = seq(0, max(df$size_p), length.out = 4), colour = "gray80", lwd=.2) +
  geom_hline(yintercept = max(df$size_p), colour = "black", lwd=1) +
  coord_polar(start =-35*(pi/(4*step)), direction = -1) +
  ggtitle(ISO_3166_1 %>% filter(Alpha_2==country_to_plot) %>% select(Name) %>% as.character)+
  scale_x_discrete(breaks=c(0,90,180,270),
                   labels=c("Right","Up","Left","Down"))+
  scale_y_continuous(limits=c(0, max(df$size_p)+0.02)) +
  theme_xkcd() +
  theme(panel.background = element_rect(fill="white", color="white"),
        plot.title       = element_text(hjust = 0.5, size=24),
        panel.grid       = element_blank(),
        axis.ticks.y     = element_blank(),
        axis.text.y      = element_blank(),
        axis.text.x      = element_text(size=14),
        axis.title       = element_blank())
