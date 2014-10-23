# run_analysis.R 
# for https://class.coursera.org/getdata-008/
# by Martin Kuhne

# Summary of tasks
# 1. Merge the training and the test sets to create one data set
# 2. Extract only the measurements on the mean and standard deviation for each measurement
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive variable names
# 5. From the data set in step 4, creates a second, independent tidy data set
#    with the average of each variable for each activity and each subject.

library(dplyr)
library(data.table)
library(reshape2)
setwd("~/datascience/3.obtaining/UCI HAR Dataset")

# returns a vector of column names to be used with the data
tidyColumnNames <- function()
{
  features <- tbl_dt(read.table("features.txt", header=F, stringsAsFactors=F))
  # doc: filter out the () and - as they add no value and may look like expressions to R
  tidyFeatures <- gsub("\\(\\)", "", features$V2, perl = FALSE)
  tidyFeatures <- gsub("\\-", "_", tidyFeatures, perl = FALSE)
  
  # all names we are going to use contain the word "Body"
  # so there is no value in having it
  tidyFeatures <- gsub("Body", "", tidyFeatures)
  
  # spell out Accelerometer and Gyroscope
  tidyFeatures <- gsub("Acc", "Accelerometer", tidyFeatures)
  tidyFeatures <- gsub("Gyro", "Gyroscope", tidyFeatures)
  
  tidyFeatures
}

# return a human readable name for an encoded column name
# Examples: tGravityAccMag_mean, tBodyAccMag_std, tGyroscopeJerk_mean_Y
# Returns: (example) StdDev over Frequency of GyroscopeJerkMag
# Remarks: alternatively, use gregexpr("^(?<sensor>Acc|Gyro)_(?<aggregate>mean|std)_*(?<coordinate>X|Y|Z)*", "Acc_mean_X", perl=T)

tidyColumnNamePass2 <- function(name)
{
  tokens <- strsplit(name, "_")[[1]]
  if (length(tokens) < 2)
  {
    return(name)
  }
  
  # break down into components and then reassemble
  dimension <- substr(tokens[[1]], 1, 1)
  variable <- substr(tokens[[1]], 2, nchar(tokens[[1]]))
  aggregate <- tokens[[2]]
  
  dimension <- if (dimension == 'f') "Frequency of " else ""
  aggregate <- if (aggregate == 'mean') "Mean over " else "StdDev over "
  coordinate <- if (length(tokens) < 3) "" else paste("(", tokens[[3]], ")", sep="")
  
  variable <- paste(aggregate, dimension, variable, coordinate, sep="")
  
  # if it ends on "Mag" we are looking at Magnitude
  variable <- gsub("Mag$", "Magnitude", variable)

  variable <- gsub("jerk", "Jerk", variable)
  variable
}

# Load all the available data, but avoid making changes to it
getMergedData <- function()
{
  # doc: the missing datapoints were filled
  testData <- tbl_dt(read.table("test/X_test.txt", header=F, stringsAsFactors=F, fill=T))
  trainData <- tbl_dt(read.table("train/X_train.txt", header=F, stringsAsFactors=F, fill=T))    
  
  stopifnot(ncol(testData) == ncol(trainData))
  
  testTrain <- rbind(testData, trainData)
  testTrain
}

# return a table with the same rowcount as the data, containing subject and activity
getSubjectAndActivity <- function()
{
  # read the subject and activity information
  subjectTest  <- tbl_dt(read.table("test/subject_test.txt", header=F, stringsAsFactors=F))
  subjectTrain <- tbl_dt(read.table("train/subject_train.txt", header=F, stringsAsFactors=F))
  subjectMerged <- rbind(subjectTest, subjectTrain)
  
  yTest  <- tbl_dt(read.table("test/y_test.txt", header=F, stringsAsFactors=F))
  yTrain <- tbl_dt(read.table("train/y_train.txt", header=F, stringsAsFactors=F))
  activityMerged <- rbind(yTest, yTrain)
  
  subjectAndActivity <- cbind(subjectMerged, activityMerged)
  setnames(subjectAndActivity, c("SubjectId", "ActivityId"))
  
  stopifnot(ncol(subjectAndActivity) == 2)
  stopifnot(nrow(subjectAndActivity) == 10299)
  
  subjectAndActivity
}

getActivityLabels <- function()
{
  # read the activity table 
  activityLabels <- tbl_dt(read.table("activity_labels.txt", header=F, stringsAsFactors=F))
  setnames(activityLabels, c("ActivityId", "Activity"))
  activityLabels
}

# overview of raw data
# subject_train etc. has all the values
# for each row, the acticity id is in y_train/y_test and the activity label is in activity_labels
# for each column, the column label is in features.txt

tidy <- getMergedData()

# doc: colunm names were introduced
setnames(tidy, tidyColumnNames())

# doc: the test and train datasets were merged

# Build a list of columns we are interested in. Drop the rest.
# Examples: tGravityAccMag_mean, tBodyAccMag_std (but not meanFreq, see the regex below)
selectedColumns <- grep("mean_|mean$|std", colnames(tidy) , value=TRUE, perl=FALSE)

# remove the gravity information
selectedColumns <- selectedColumns[!grepl("tGravity", selectedColumns)]  
# get the columns we want to continue to work with
tidy <- tidy[, selectedColumns, with = FALSE]

# merge with subject and activity data
tidy <- cbind(getSubjectAndActivity(), tidy)

stopifnot(nrow(tidy) == 10299) # same as before

# set the refined column names
setnames(tidy, sapply(names(tidy), tidyColumnNamePass2))

# transpose into a tall table with variable/value pairs
tidyTall <- reshape2::melt(tidy, id.vars = c("SubjectId", "ActivityId"))
tidyTall$Activity <- factor(tidyTall$Activity)

# transpose it into a set of sums per subject and activity
final <- reshape2::dcast(tidyTall, SubjectId + ActivityId ~ variable, mean)

# bind main data with acticity labels
final <- left_join(final, getActivityLabels(), by="ActivityId")
final <- within(final, rm(ActivityId))

final <- final[, c(grep(" ", names(final), value=T, invert=T), grep(" ", names(final), value=T))]

# sort
final <- dplyr::arrange(final, SubjectId, Activity)

setwd("~/datascience/3.obtaining")
write.table(final, "getdata-008.txt", row.names=FALSE)

