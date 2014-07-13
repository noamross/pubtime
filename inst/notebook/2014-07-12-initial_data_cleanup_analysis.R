library(data.table)
library(dplyr)
library(pubtime)
library(stringi)
library(pander)

files = system.file("journal_data", list.files(system.file("journal_data", package="pubtime")), package="pubtime")
pubtimes_list = lapply(files, read_pubtimes_csv)
pubtimes = rbindlist(pubtimes_list)
rm(pubtimes_list)

pubtimes = droplevels(pubtimes[!(journal %in% c("Ecosystems", "Oecologia")),])

pubtimes[, error := ifelse(is.na(error), FALSE, error)]

incompletes = pubtimes %>% 
  group_by(journal) %>%
  summarize(received=sum(is.na(received) & !error), 
            accepted=sum(is.na(accepted) & !error),
            reversed=sum(received > accepted, na.rm=TRUE),
            error = sum(error),
            tot_err = sum(is.na(received) | is.na(accepted) | error | (received > accepted)),
            total=length(error)) %>%
  mutate(frac_err = tot_err/total) %>%
  arrange(desc(tot_err))


incompletes
pandoc.table


## Find editors that are spelled differently by matching last names

lastnames = stri_match_first_regex(levels(pubtimes$editor), "(?<=\\s)\\w+$", 
                       stri_opts_regex(case_insensitive = TRUE))
eds = levels(pubtimes$editor)[order(lastnames)]
lastnames=sort(lastnames)
eds[duplicated(lastnames) | duplicated(lastnames, fromLast=TRUE)]

## Play with data

fullpt = pubtimes %>% filter(!(error | is.na(received) | is.na(accepted) | (received > accepted) | accepted < as.Date("01-01-2014")))

library(ggplot2)

fullpt[, wait := as.integer(accepted-received)]
medians = fullpt %>% group_by(journal) %>% summarize(median_wait= as.double(median((wait)))) %>% arrange(median_wait)
fullpt$journal = factor(fullpt$journal, levels = as.character(medians$journal))


trimmed_fullpt = ddply(as.data.frame(fullpt), .(journal), function(x) {
  y = x$wait
  #y = log(x$wait)
  q = quantile(y, probs=c(0.25, 0.75))
  IQR = q[2] - q[1]
  min = q[1] - 1.5*IQR
  max = q[2] + 1.5* IQR
  trimmed = x[y > min & y < max,]
  return(trimmed)
  })

outliers_fullpt = ddply(as.data.frame(fullpt), .(journal), function(x) {
  y = x$wait
  #y = log(x$wait)
  q = quantile(x$wait, probs=c(0.25, 0.75))
  IQR = q[2] - q[1]
  min = q[1] - 1.5*IQR
  max = q[2] + 1.5* IQR
  trimmed = x[x$wait <= min | x$wait >= max,]
  return(trimmed)
  })

ggplot(outliers_fullpt, aes(y = wait, x=journal, fill=journal, col=journal)) + 
  geom_boxplot(data=fullpt, fill=NA, color="grey", outlier.colour=NA, width=0.25) +
  geom_violin(data=trimmed_fullpt, alpha = 0.5, adjust=0.5, scale="width", width=0.65) +
  geom_point(alpha=0.5) +
  scale_x_discrete(labels=paste0(levels(fullpt$journal), "\nn = ", ddply(fullpt, .(journal), nrow)$V1)) +
#  scale_y_continuous(breaks=seq(0,1000, by=120)) +
  scale_y_log10(breaks=c(7, 14, 30, 60, 90, 180, 360, 720)) +  
  coord_flip() +
  theme(legend.position="none",
        panel.grid.major.x=element_line(colour="grey", size=0.5, linetype=1),
        panel.grid.major.y=element_blank(),
        panel.grid.minor.x=element_blank(),
        panel.grid.minor.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.background=element_blank(),
        text=element_text(family="Lato", size=14),
        axis.title=element_text(size=18),
        axis.text=element_text(color="black",size=13)) +
        ggtitle(expression(atop("Received-to-Accept Wait Time by Journal", atop("ordered by median wait time")))) +
  xlab("") + ylab("Days")
