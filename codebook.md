---
title: "Activity data code book"
author: "Martin Kuhne"
date: "10/22/2014"
output: html_document
---

# Desciptions and measurements on the Gyroscope and Accelerometer sensor readings

Position | Variable  | Description
---------|-----------|------------
1        | SubjectId | Identifier of the subject performing the test [Integer]
2        | Activity  | Identifier of the test performed [String]
3..60    | Variables | see below

Variables each contain the following elements

Position | Variable  | Description
---------|-----------|------------
1        | Aggregate function | "StdDev" = Standard Deviation, "Mean"= Mean
2        | Dimension | "Frequency" or "Time" (if left blank)
3        | Measurement | "Accelerometer" or "Time" (if left blank)
4        | Coordinate | "X", "Y" or "Z"

Measurements each contain the following elements

Position | Variable  | Description
---------|-----------|------------
1        | Sensor | "Accelerometer" or "Gyroscope"
2        | Jerk | "Jerk" or "no Jerk" (if left blank)
3        | Magnitude | "Magnitude" or "no Magnitude" (if left blank)
