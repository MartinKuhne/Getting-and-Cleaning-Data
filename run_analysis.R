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

library("dplyr")
library("data.table")
setwd("~/datascience/3.obtaining/UCI HAR Dataset")

# returns a vector of column names to be used with the data
tidyColumnNames <- function()
{
    features <- tbl_dt(read.table("features.txt", header=F, stringsAsFactors=F))
    # doc: filter out the () and - as they add no value and may look like expressions to R
    tidyFeatures <- gsub("\\(\\)", "", features$V2, perl = FALSE)
    tidyFeatures <- gsub("\\-", "_", tidyFeatures, perl = FALSE)
    tidyFeatures
}

# 1. Merge the training and the test sets to create one data set
getMergedData <- function()
{
    # doc: the missing datapoints were filled
    testData <- tbl_dt(read.table("test/X_test.txt", header=F, stringsAsFactors=F, fill=T))
    trainData <- tbl_dt(read.table("train/X_train.txt", header=F, stringsAsFactors=F, fill=T))    
    
    ncol(testData) == 561 # observation
    ncol(trainData) == 561 # observation
    
    nrow(testData) == 2947 # wc
    nrow(trainData) == 7352 # wc
    
    allData = rbind(testData, trainData)
    allData
}

# overview of raw data
# subject_train etc. has all the values
# for each row, the acticity id is in y_train/y_test and the activity label is in activity_labels
# for each column, the column label is in features.txt

mergedData <- getMergedData()

# doc: colunm names were introduced
tidyFeatures = tidyColumnNames()
setnames(mergedData, tidyFeatures)

activityLabels <- tbl_dt(read.table("activity_labels.txt", header=F, stringsAsFactors=F))

subjectTrain = tbl_dt(read.table("train/subject_train.txt", header=F, stringsAsFactors=F))
subjectTest  = tbl_dt(read.table("test/subject_test.txt", header=F, stringsAsFactors=F))

yTrain = tbl_dt(read.table("train/y_train.txt", header=F, stringsAsFactors=F))
yTest  = tbl_dt(read.table("test/y_test.txt", header=F, stringsAsFactors=F))

sort(unique(yTrain$V1)) == unique(activityLabels$V1)

# doc: the test and train datasets were merged
ncol(allData) == ncol(testData)

# 2. Extract only the measurements on the mean and standard deviation for each measurement
selectedColumns <- grep("min|std", colnames(allData) , value=TRUE, perl=FALSE)
tidy = allData[, selectedColumns, with = FALSE]

ncol(tidy) == 66 # observation
nrow(tidy) == 10299 # observation


