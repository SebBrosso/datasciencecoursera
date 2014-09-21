# Readme for the project dataset

This document describes the how to use the R script *run_analysis.R* to generate the datasets of the project assignment for the Coursera Getting and Cleaning Data course.

See [CookBook](CookBook.md) for more information on the created datasets.

# Pre-requisites

The *run_analysis* script needs to be run on the directory containing the "UCI HAR Dataset" directory provided as a zip file on the course assignment page.

# Creating the tidy dataset

Note: this corresponds to question 1 to 4

Creating the tidy dataset is done by calling the *createDataset* function.

This function creates a single dataset from "UCI HAR Dataset" by combining test and training data. In addition, it uses other files from the dataset to lookup for activity and feature names and correctly label the columns.

The default arguments for this function are set to work in the environment described in the Pre-requisites. Although, if you want to run the script in different conditions, you can use the following arguments:
* rootDir: A string corresponding to the root directory of the dataset. Default is "UCI HAR Dataset".
* datasets: A vector containing the list of datasets to merge. Default is c("test", "train").

The `createDataset` function returns the resulting dataset (data frame).

Sample usage:
```R
> data <- createDataset()

> data <- createDataset(rootDir = "C:/temp/UCI HAR Dataset", datasets = c('test1', 'test2', 'train'))
```

# Computing the statistics dataset

Note: this corresponds to question 5

Creating the statistics dataset is done by calling the `computeStats` function.

This function computes the average of each variable for each activity and each subject on the given dataset computed with `createDataset`.

It takes the following arguments:
* data: A data frame created using createDataset
* output: A string containing the name of the file to store data into. Default is NULL, meaning no file output

The `computeStats` function returns the resulting dataset (data frame).

Sample usage:
```R
> data <- createDataset()
> stats <- computeStats(data)
> stats2 <- computeStats(data, output = "output.txt")
```
