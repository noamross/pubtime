
require(pubtime)
require(ggplot2)
require(plyr)

data(pubtimes)

pubtimes$accepttime = as.integer(pubtimes$accepted - pubtimes$submitted)
pubtimes$printtime = as.integer(pubtimes$online - pubtimes$accepted)
pubtimes$totaltime = as.integer(pubtimes$online - pubtimes$submitted)

plos_journals = c("PLoS ONE", "PLoS Computational Biology", "PLoS Biology", 
             "PLoS Medicine", "PLoS Pathogens", "PLoS Neglected Tropical Diseases",
             "PLoS Genetics")

dat = subset(pubtimes, journal %in% plos_journals & accepttime > 0)

require(ggplot2)
ggplot(dat, aes(y = accepttime, x = journal)) + 
  geom_boxplot(alpha = 0.75, fill="slateblue") +
#  geom_jitter(position = position_jitter(width = .05), size=2) +
  scale_x_discrete(labels=paste0(levels(dat$journal), "\nn = ", ddply(dat, .(journal), nrow)$V1)) +
  scale_y_log10() + 
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
        ggtitle("Submit-to-Accept times of Ecology articles in PLoS Journals") +
  xlab("") + ylab("Days (log scale)")


ggplot(dat, aes(y = printtime, x = journal, fill=journal, col=journal)) + 
  geom_violin(alpha = 0.5, linetype=0, adjust=0.5) +
  scale_x_discrete(labels=paste0(levels(dat$journal), "\nn = ", ddply(dat, .(journal), nrow)$V1)) +
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
        ggtitle("Accept-to-Publish times of Ecology articles in PLoS Journals") +
  xlab("") + ylab("Days")


ggplot(dat, aes(x = online, y= accepttime)) +
  geom_point(size=1, alpha=0.75, col="slateblue") +
  geom_smooth() +
  theme(legend.position="bottom",
        panel.grid.major.x=element_blank(),
        panel.grid.major.y=element_line(colour="grey", size=0.5, linetype=1),
        panel.grid.minor.x=element_blank(),
        panel.grid.minor.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.background=element_blank(),
        text=element_text(family="Lato", size=14),
        axis.title=element_text(size=18),
        axis.text=element_text(color="black",size=13)) +
    ggtitle("Received-to-Accept times over time at PLoS")

dat2 = subset(dat, journal=="PLoS ONE")
dat2=droplevels(dat2)
eds = ddply(dat2, .(editor), summarize, Mean=mean(accepttime),
            Median = median(accepttime),
            SD=sd(accepttime), N=length(accepttime))

eds = eds[order(eds$N, decreasing=FALSE),]
eds= droplevels(eds)

dat2$editor = factor(dat2$editor,
                    levels = eds$editor[order(eds$Median, decreasing=FALSE)])
eds$editor = factor(eds$editor,
                    levels = eds$editor[order(eds$Median, decreasing=FALSE)])
MIN_ARTICLES = 25
bigeds = droplevels(eds[eds$N > MIN_ARTICLES,])
bigeds = bigeds[order(bigeds$Median), ]

ggplot(subset(dat2, editor %in% bigeds$editor), aes(y=accepttime, x=editor)) +
  scale_x_discrete(labels=paste0(levels(bigeds$editor), " (", bigeds$N, ")")) +
  geom_boxplot(fill="slateblue", alpha=0.5) +
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
  ggtitle("Received-to-Accept times in Ecology \nArticles in PLoS ONE by Editor") +
  ylab("Handling time in days") +
  xlab(paste0("Editor (No. articles handled, must be > ", MIN_ARTICLES, ")"))


ggplot(eds, aes(x = N, y=Mean)) + 
  geom_point(col="slateblue") +
  theme(legend.position="bottom",
        panel.grid.major.x=element_blank(),
        panel.grid.major.y=element_line(colour="grey", size=0.5, linetype=1),
        panel.grid.minor.x=element_blank(),
        panel.grid.minor.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.background=element_blank(),
        text=element_text(family="Lato", size=14),
        axis.title=element_text(size=18),
        axis.text=element_text(color="black",size=13)) +
  xlab("No. of papers handled") +
  ylab("Mean handling time") +
  ggtitle("Editor handling times by experience in PLoS journals")


