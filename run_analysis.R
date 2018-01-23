##############################
# Coursera Get and Clean Data
# Week 4: Final Project
##############################

rm( list = ls() )

library(dplyr)

# download zip file and unzip files
if ( !file.exists("finalProject.zip")) {
  url_zip <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url_zip, "finalProject.zip")
}

if (!file.exists("UCI HAR Dataset")) { 
  unzip("finalProject.zip") 
}

# read feature names and activity labels
data_colname <- read.csv("./UCI HAR Dataset/features.txt", sep = "", header = FALSE)
data_activityLabel <- read.csv("./UCI HAR Dataset/activity_labels.txt", sep = "", header = FALSE, col.names = c("activity_num", "activity"))

colnames <- as.character(data_colname[, 2])

# read data sets
data_Xtrain <- read.csv("./UCI HAR Dataset/train/X_train.txt", sep = "", col.names = colnames)
data_ytrain <- read.csv("./UCI HAR Dataset/train/y_train.txt", sep = "", col.names = "activity_num")
data_subject_train <- read.csv("./UCI HAR Dataset/train/subject_train.txt", sep = "", col.names = "subject")

data_Xtest <- read.csv("./UCI HAR Dataset/test/X_test.txt", sep = "", col.names = colnames)
data_ytest <- read.csv("./UCI HAR Dataset/test/y_test.txt", sep = "", col.names = "activity_num")
data_subject_test <- read.csv("./UCI HAR Dataset/test/subject_test.txt", sep = "", col.names = "subject")

# 1. merge training and test data sets, remove original data sets
data_X <- rbind(data_Xtrain, data_Xtest)
data_y <- rbind(data_ytrain, data_ytest)
data_subject <- rbind(data_subject_train, data_subject_test)

data_all <- cbind(data_subject, data_y, data_X)

list_to_remove <- ls() [ grep("_X|_y|_subject", ls()) ]
rm(list = list_to_remove)

# 2. find col number of vars that measures either mean or std , then substract features measured in mean and std 
index_col <- grep("[Mm]ean|[Ss]td", names(data_all))

   # add col 1:2 to keep col subject and activity as well
index_col <- c(1:2, index_col)

data_all_keep <- data_all[ , index_col]

# 3. use descriptive activity names to name the activities in the data set
data_all_keep2 <- merge( data_all_keep, data_activityLabel, by.x = "activity_num", by.y = "activity_num" )

data_all_keep2 <- data_all_keep2 %>%
                  select( - activity_num ) 

   # change order of column, since after merging, activity goes to the last
colnames <- names(data_all_keep)
colnames[2] <- "activity"

data_all_keep2 <- data_all_keep2[colnames]

    # alternatively
    # data_all_keep3$activity_num<-factor(data_all_keep3$activity_num, levels = data_activityLabel[ , 1], labels = data_activityLabel[ ,2])
    # data_all_keep3 <- rename(data_all_keep3, activity = activity_num)


# 4. appropriately labels the data set with descriptive variable names
colnames <- gsub(".mean", "Mean", colnames)
colnames <- gsub(".std", "Std", colnames)
colnames <- gsub("\\.", "", colnames)
colnames <- gsub("\\.", "", colnames)
colnames <- gsub("\\.", "", colnames)

names(data_all_keep2) <- colnames

# 5. From the data set in step 4, creates a second, independent tidy data set 
   # with the average of each variable for each activity and each subject
data_average <- data_all_keep2 %>% group_by(subject, activity) %>% summarise_all("mean")

   # write.csv
write.csv(data_average, "data_tidy.csv")
write.table(data_average, "data_tidy.txt", row.name = FALSE )
