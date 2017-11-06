install.packages("readr")
install.packages("dplyr")
install.packages("zoo")
install.packages("rgexf")
install.packages("plyr")
library(readr)
library(dplyr)
library(zoo)
library(rgexf)
library(plyr)

### Read original .tsv dataset

MusicData <- read_delim("C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/lastfm-dataset-1K/userid-timestamp-artid-artname-traid-traname.tsv", 
                        "\t", escape_double = FALSE, col_names = FALSE, 
                        trim_ws = TRUE)

UserData <- read_delim("C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/lastfm-dataset-1K/userid-profile.tsv", 
                       "\t", escape_double = FALSE, trim_ws = TRUE)

### Format and clean dataset [version 1] (removed incomplete cases)

colnames(MusicData) <- c("usrid","time","artid","artist","sngid","song")
MusicData <- MusicData[complete.cases(MusicData),]
UserData <- UserData[complete.cases(UserData),]
MusicData <- MusicData[MusicData$userid %in% UserData$'#id',]

### Export clean dataset as .csv [verison 2]

write_csv(MusicData,"C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/lastfm-dataset-1K/MusicData.csv",col_names = TRUE)
write_csv(UserData,"C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/lastfm-dataset-1K/UserData.csv",col_names = TRUE)

### Format and clean dataset [version 2] (only listened by US audience with 5000 plays)

UserData <- UserData[UserData$country %in% tail(names(sort(table(UserData$country))), 3),]
UserData <- UserData[complete.cases(UserData$`#id`),]
MusicData <- MusicData[MusicData$usrid %in% UserData$'#id',]
UserData$Count <- 0
for(Idx in 1:nrow(UserData)){
  tempsubset <- MusicData[MusicData$usrid == UserData$`#id`[Idx],]
  UserData$Count[Idx] <- nrow(tempsubset)
}
UserData <- UserData[UserData$Count >= 5000,]
MusicData <- MusicData[MusicData$usrid %in% UserData$'#id',]

### Export clean dataset as .csv [verison 2]

write_csv(MusicData,"C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/lastfm-dataset-1K/MusicData_v2.csv",col_names = TRUE)
write_csv(UserData,"C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/lastfm-dataset-1K/UserData_v2.csv",col_names = TRUE)

### Aggregate dataset by month

ArtistData <- MusicData[,3:4]
ArtistData <- ArtistData[!duplicated(ArtistData$artid),]
MusicData <- MusicData[,1:3]
MusicData$time <- as.yearmon(MusicData$time)
MusicData <- arrange(MusicData,time,usrid,artid)
n <-  4 # this value changes depending on the n-th computer I used to run this code
startmonth <- min(MusicData$time)+(n)
endmonth <- startmonth+11/12
for(month in seq(startmonth,endmonth,(1/12))){
  MonthData <- data.frame("user"=NA,"artist"=NA,"year.month"=NA,"number"=NA)
  tempsubset1 <- MusicData[MusicData$time==month,]
  for(user in unique(tempsubset1$usrid)){
    tempsubset2 <- tempsubset1[tempsubset1$usrid==user,]
    for(artist in unique(tempsubset2$artid)){
      tempsubset3 <- tempsubset2[tempsubset2$artid==artist,]
      MonthData <- rbind(MonthData,c(user,artist,month,nrow(tempsubset3)))
      print(paste("File",month,"-",nrow(MonthData)))
    }
  }
  MonthData <- MonthData[complete.cases(MonthData),]
  write_csv(MonthData,paste("C:/Users/1001690/Desktop/ProcessFarm/MonthData_",month,".csv"),col_names = TRUE)
}
MonthData <- MonthData[complete.cases(MonthData),]

### Create consolidated dataset for all monthly datasets

files <- list.files(path="C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/MonthData/", pattern="*.csv", full.names=TRUE, recursive=FALSE)
MonthData <- read_csv(files[1])
for(file in files[2:120]){
  tempdf <- read_csv(file)
  MonthData <- rbind(MonthData,tempdf)
  rm(tempdf)
}
MonthData <- MonthData[complete.cases(MonthData),]
MonthData <- arrange(MonthData,year.month,user,artist)
write_csv(MonthData,"C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/MonthData.csv",col_names = TRUE)

### Create temporal graph (.gexf) using dataset

usrnodelist <- data.frame("id"=unique(MonthData$user),"label"=unique(MonthData$user))
artnodelist <- data.frame("id"=unique(MonthData$artist),"label"=unique(MonthData$artist))
nodelist <- rbind(usrnodelist,artnodelist)
rm(usrnodelist)
rm(artnodelist)
edgelist <- MonthData[,1:2]
edgeweight <- MonthData$number
edgedynamic <- data.frame("start"=as.Date(as.yearmon(MonthData$year.month)),"end"=as.Date(as.yearmon(MonthData$year.month+(1/12))))
write.gexf(nodes = nodelist,edges = edgelist,edgesWeight = edgeweight,edgeDynamic = edgedynamic,tFormat = "date",output = "C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/MonthData.gexf")

### Create cocitation graph for every month

ArtistData <- MusicData_v2[,3:4]
ArtistData <- ArtistData[!duplicated(ArtistData$artid),]
rm(MusicData_v2)
CociteData <- data.frame("node1"=NA,"node2"=NA,"weight"=NA,"month"=NA)
n <- 1
ProcessSet <- unique(MonthData$year.month)[(1*n):(6*n)]
for(month in ProcessSet){
  tempsubset1 <- MonthData[MonthData$year.month == month,]
  for(artist1 in unique(tempsubset1$artist)){
    tempsubset2 <- tempsubset1[tempsubset1$artist == artist1,]
    user1 <- tempsubset2$user
    for(artist2 in unique(tempsubset1$artist[tempsubset1$artist != artist1])){
      tempsubset3 <- tempsubset1[tempsubset1$artist==artist2,]
      user2 <- tempsubset3$user
      uvweight <- 0
      if(length(intersect(user1,user2))!=0){
        for(common in intersect(user1,user2)){
          uvweight <- uvweight + (tempsubset2[tempsubset2$user==common,4]*tempsubset3[tempsubset3$user==common,4])
        }
        CociteData <- rbind(CociteData,setNames(c(artist1,artist2,uvweight,month),names(CociteData)))
        print(paste("File",month,"-",nrow(CociteData)))
      }
    }
  }
  CociteData <- CociteData[complete.cases(CociteData),]
  write_csv(MonthData,paste("C:/Users/1001690/Desktop/ProcessFarm/CociteData_",month,".csv"),col_names = TRUE)
}

### Format and clean dataset [version 3] (only top 1000 artists listened by US audience with 5000 plays)

UserData_v2 <- UserData_v2[UserData_v2$country=="United States",]
UserData_v2 <- UserData_v2[,c(1,4)]
MusicData_v2 <- MusicData_v2[MusicData_v2$usrid %in% UserData_v2$'#id',]
MusicData_v2 <-  MusicData_v2[MusicData_v2$artid %in% tail(names(sort(table(MusicData_v2$artid))), 1000),]
ArtistData <- MusicData_v2[!duplicated(MusicData_v2$artid),]
ArtistData <- ArtistData[,3:4]

### Export clean dataset as .csv [verison 3]

write_csv(ArtistData,paste("C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/US1kArtistData.csv"),col_names = TRUE)
write_csv(UserData_v2,paste("C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/US1kUserData.csv"),col_names = TRUE)
write_csv(MusicData_v2,paste("C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/US1kMusicData.csv"),col_names = TRUE)

### Aggregate dataset by month

MusicData_v2 <- MusicData_v2[,1:4]
MusicData_v2$time <- as.yearmon(MusicData_v2$time)
MusicData_v2 <- arrange(MusicData_v2,time,usrid,artid)
MonthData <- data.frame("user"=NA,"artist"=NA,"year.month"=NA,"number"=NA)
#n <- 0
startmonth <- min(MusicData_v2$time)
endmonth <- max(MusicData_v2$time)
ProcessSet <- seq(startmonth,endmonth,(1/12))#[(1+6*n):(6+6*n)]
for(month in ProcessSet){
  tempsubset1 <- MusicData_v2[MusicData_v2$time==month,]
  for(user in unique(tempsubset1$usrid)){
    tempsubset2 <- tempsubset1[tempsubset1$usrid==user,]
    for(artist in unique(tempsubset2$artid)){
      tempsubset3 <- tempsubset2[tempsubset2$artid==artist,]
      MonthData <- rbind(MonthData,c(user,artist,month,nrow(tempsubset3)))
      print(paste("File",as.Date(as.yearmon(month)),"-",nrow(MonthData)))
    }
  }
}
MonthData <- MonthData[complete.cases(MonthData),]
write_csv(MonthData,paste("C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/MonthData.csv"),col_names = TRUE)

### Aggregate dataset by complete duration (2005-2009)

TotalData <- data.frame("user"=NA,"artist"=NA,"number"=NA)
tempsubset1 <- MonthData
for(user in unique(tempsubset1$user)){
  tempsubset2 <- tempsubset1[tempsubset1$user==user,]
  for(artist in unique(tempsubset2$artist)){
    tempsubset3 <- tempsubset2[tempsubset2$artist==artist,]
    TotalData <- rbind(TotalData,c(user,artist,nrow(tempsubset3)))
    print(paste("Row: ",nrow(TotalData)))
  }
}
TotalData <- TotalData[complete.cases(TotalData),]
write_csv(TotalData,paste("C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/TotalData.csv"),col_names = TRUE)

### Create Cocitation dataset for complete duration

TotalData$number <- as.integer(TotalData$number)
TotalCociteData <- data.frame("Source"=NA,"Target"=NA,"Weight"=NA,"Type"=NA)
tempsubset1 <- TotalData
combilist <- combn(unique(tempsubset1$artist),2)
for(row in 1:499500){
  artist <- combilist[,row]
  tempsubset2 <- tempsubset1[tempsubset1$artist == artist[1],]
  user1 <- tempsubset2$user
  tempsubset3 <- tempsubset1[tempsubset1$artist==artist[2],]
  user2 <- tempsubset3$user
  uvweight <- 0
  if(length(intersect(user1,user2))!=0){
    for(common in intersect(user1,user2)){
      uvweight <- uvweight + (tempsubset2[tempsubset2$user==common,3]*tempsubset3[tempsubset3$user==common,3])
    }
    TotalCociteData <- rbind(TotalCociteData,setNames(c(artist[1],artist[2],uvweight,"Undirected"),names(TotalCociteData)))
      print(paste("Row: ",nrow(TotalCociteData)))
  }
}
TotalCociteData <- TotalCociteData[complete.cases(TotalCociteData),]
write_csv(TotalCociteData,paste("C:/Users/CRAZY/PycharmProjects/Small_Projects/NMProject/TotalCociteData.csv"),col_names = TRUE)

### Alternative code for cocitation (faster runtime)

n <- 0
ProcessSet <- unique(MonthData$year.month)[(1+6*n):(6+6*n)]
for(month in ProcessSet){
  CociteData <- data.frame("Source"=NA,"Target"=NA,"Weight"=NA,"Type"=NA,"month"=NA)
  tempsubset1 <- MonthData[MonthData$year.month == month,]
  for(row in 1:499500){
    artist <- combilist[,row]
    tempsubset2 <- tempsubset1[tempsubset1$artist == artist[1],]
    user1 <- tempsubset2$user
    tempsubset3 <- tempsubset1[tempsubset1$artist == artist[2],]
    user2 <- tempsubset3$user
    uvweight <- 0
    if(length(intersect(user1,user2))!=0){
      for(common in intersect(user1,user2)){
        uvweight <- uvweight + (tempsubset2[tempsubset2$user==common,4]*tempsubset3[tempsubset3$user==common,4])
      }
      CociteData <- rbind(CociteData,setNames(c(artist[1],artist[2],uvweight,"Undirected",month),names(CociteData)))
        print(paste("File",month,"-",nrow(CociteData)))
    }
  }
  CociteData <- CociteData[complete.cases(CociteData),]
  write_csv(CociteData,paste("C:/Users/1001690/Desktop/ProcessFarm_v5/CociteData_",month,".csv"),col_names = TRUE)
}

### Create top 20 ranking artist for every month (by artist index)

RankMonth <- data.frame(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA)
colnames(RankMonth) <- c("Month",20:1)
startmonth <- min(MusicData_v2$time)
endmonth <- max(MusicData_v2$time)
ProcessSet <- seq(startmonth,endmonth,(1/12))
for(month in ProcessSet){
  tempsubset1 <- MusicData_v2[MusicData_v2$time==month,]
  rowvec <- c(month,tail(names(sort(table(tempsubset1$artid))), 20))
  RankMonth <- rbind(RankMonth,setNames(rowvec,names(RankMonth)))
  print(paste("Month: ",as.Date(as.yearmon(month))))
}
RankMonth <- RankMonth[complete.cases(RankMonth),]
write_csv(RankMonth,paste("C:/Users/1001690/Desktop/ProcessFarm_v5/RankMonth.csv"),col_names = TRUE)

### Create top 20 ranking artist for every month (by artist name)

RankMonthName <- data.frame(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA)
colnames(RankMonthName) <- c("Month",20:1)
startmonth <- min(MusicData_v2$time)
endmonth <- max(MusicData_v2$time)
ProcessSet <- seq(startmonth,endmonth,(1/12))
for(month in ProcessSet){
  tempsubset1 <- MusicData_v2[MusicData_v2$time==month,]
  rowvec <- c(month,tail(names(sort(table(tempsubset1$artist))), 20))
  RankMonthName <- rbind(RankMonthName,setNames(rowvec,names(RankMonthName)))
  print(paste("Month: ",as.Date(as.yearmon(month))))
}

RankMonthName <- RankMonthName[complete.cases(RankMonthName),]
write_csv(RankMonthName,paste("C:/Users/1001690/Desktop/ProcessFarm_v5/RankMonthName.csv"),col_names = TRUE)


