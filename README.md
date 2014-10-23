---
Title: About the tidy data set
Author: Martin Kuhne
date: "10/22/2014"
output: html_document
references:
- id: faq
  title: Do we need the inertial folder
  URL: 'https://class.coursera.org/getdata-008/forum/thread?thread_id=24'
---

About the data cleanup script
=========================

Welcome to the tidy data script for the [getdata-008](https://class.coursera.org/getdata-008) class. This readme explains what steps were performed to transform the data and provides a high level overview of how it was accomplished.

## Summary of tasks
### Merge the training and the test sets to create one data set

As per the instructors's recommendation [@faq], the raw data was ignored for this exercise.

The refined data is loaded into a single frame and this frame is used for further processing. As for the data itself, it is spread out across seveal files with an implied relationship by line numbers, The *test* and *training* data have the same column count and the subject data shows the same row count as the *test* and *training* data.

### Extract only the measurements on the mean and standard deviation for each measurement

According to the data book, mean() indicates the mean and std the standard deviation. There is some ambiguity as the mean can show up in two forms, either as `_mean_` or `Mean` at the end of the variable name. Both iterations of "mean" were selected, the other colums discarded.

### Use descriptive activity names to name the activities in the data set

A lookup table was provided with the orginal data, which is then used for a substitution from ActivityId to Activity.

### Appropriately label the data set with descriptive variable names

The variable names can be broken down into aggregate (sd or mean), dimension (time or frequency), variable and coordinate (X,Y or Z). The function will then return a human readable name such as "StdDev over Frequency of GyroscopeJerkMagnitude". In the interest of space, StdDev was judged to be an acceptable abbreviation.# 5. From the data set in step 4, creates a second, independent tidy data set

### Produce a final table with the average of each variable for each activity and each subject

`SubjectId + ActivityId ~ variable` is the formula to express we want to summarize by average over activity and subject.

# References