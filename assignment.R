#storm_raw<-read.csv("repdata-data-StormData.csv.bz2")

#Clean data

storm_clean<-storm_raw
storm_clean$EVTYPE<-toupper(storm_clean$EVTYPE) #Convert all EVTYPE to upper case
storm_clean<-subset(storm_clean,!grepl("^MARINE|WATERSPOUT",storm_clean$EVTYPE)) #Remove Marine type events as analysis is only for accross US
storm_clean$EVTYPE<-gsub("S$| $|^ ","",storm_clean$EVTYPE) #Remove ending S, leading and ending spaces
storm_clean$EVTYPE<-gsub(" +"," ",storm_clean$EVTYPE) #Remove repeating spaces
storm_clean$EVTYPE<-gsub("/"," ",storm_clean$EVTYPE) #Remove backlash (some items have, other have spaces)


#Injuries and Fatalities aggregate

fatalities<-aggregate(x=storm_clean[c("INJURIES","FATALITIES")],list(storm_clean$EVTYPE),sum)
names(fatalities)[1]<-c("EVTYPE")
fatalities<-subset(fatalities,INJURIES>0)
fatalities<-fatalities[with(fatalities,order(-INJURIES,EVTYPE)),]
fatalities_plot<-fatalities[1:20,]
fatalities_plot$EVTYPE[20]="OTHER"
fatalities_plot$INJURIES[20]=sum(fatalities$INJURIES[20:length(fatalities)])
fatalities_plot$FATALITIES[20]=sum(fatalities$FATALITIES[20:length(fatalities)])
#fatalities_plot$EVTYPE<-as.factor(fatalities_plot$EVTYPE,ordered=FALSE)
fatalities_plot$EVTYPE<-factor(fatalities_plot$EVTYPE,levels=unique(fatalities_plot$EVTYPE))
plot(x=fatalities_plot$EVTYPE,y=fatalities_plot$INJURIES,log="y",type="h")
#barplot(fatalities_plot)


multipliers<-data.frame(c("H","K","M","B","+","-","?","1"),c(100,1000,1000000,1000000000,1,0,0,10))
names(multipliers)<-c("code","PROPDMGMULT")
damages<-storm_clean[c("EVTYPE","PROPDMGEXP","CROPDMGEXP","PROPDMG","CROPDMG")]
damages$PROPDMGEXP<-toupper(damages$PROPDMGEXP)
damages$CROPDMGEXP<-toupper(damages$CROPDMGEXP)
damages$PROPDMGEXP<-sub("[0-9]|^$","1",damages$PROPDMGEXP) #Replace numerics and empty by 1
damages$CROPDMGEXP<-sub("[0-9]|^$","1",damages$CROPDMGEXP) #Replace numerics and empty by 1
damages_merge<-merge(damages,multipliers,by.x=c("PROPDMGEXP"),by.y=c("code"),all.x=TRUE)
names(multipliers)<-c("code","CROPDMGMULT")
damages_merge<-merge(damages_merge,multipliers,by.x=c("CROPDMGEXP"),by.y=c("code"),all.x=TRUE)
damages_merge$TOTALDMG=
	damages_merge$CROPDMG*damages_merge$CROPDMGMULT+
	damages_merge$PROPDMG*damages_merge$PROPDMGMULT
 the_na<-subset(damages_merge,is.na(TOTALDMG))
damages_agg<-aggregate(x=damages_merge[c("TOTALDMG")],list(damages_merge$EVTYPE),sum)
names(damages_agg)[1]<-c("EVTYPE")
damages_agg<-subset(damages_agg,TOTALDMG>0)
damages_agg<-damages_agg[with(damages_agg,order(-TOTALDMG)),]
