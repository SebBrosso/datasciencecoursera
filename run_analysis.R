
# Creates a single dataset from "UCI HAR Dataset" by combining test and training data 
#
# Args:
#   rootDir: A string corresponding to the root directory of the dataset. Default is "UCI HAR Dataset".
#   datasets: A vector containing the list of datasets to merge. Default is c("test", "train").
#
# Returns:
#   The tidy dataset
createDataset <- function(rootDir = "UCI HAR Dataset", datasets = c("test", "train")) {
  
  # variables to store merged datasets
  activities <- NULL
  subjects <- NULL
  measures <- NULL
  
  #### 1. Merges the training and the test sets to create one data set.
  for(dataset in datasets) {
    # dataset sub directory
    datasetDir <- paste(c(rootDir, "/", dataset))
    
    # read and append activities
    data <- read.table(paste(c(datasetDir, "/y_", dataset, ".txt"), collapse = ""), col.name = c("activity.id"))
    activities <- rbind(activities, data)
    
    # read and append subjects
    data <- read.table(paste(c(datasetDir, "/subject_", dataset, ".txt"), collapse = ""), col.names = c("subject.id"))
    subjects <- rbind(subjects, data)
    
    # read and append measures, use column labels from features.txt
    data <- read.table(paste(c(datasetDir, "/X_", dataset, ".txt"), collapse = ""))
    measures <- rbind(measures, data)
  }
  
  #### 2. Extracts only the measurements on the mean and standard deviation for each measurement.
  
  # load feature list to label measures
  features <- read.table(paste(c(rootDir, "/features.txt"), collapse = ""), col.names = c("feature.id", "feature.name"))
  
  # label column using feature names
  colnames(measures) <- features$feature.name
  
  # extract column with label containing "mean(" or "std"
  measures <- measures[,grepl("mean\\(|std", names(measures))]
  
  #### 3. Uses descriptive activity names to name the activities in the data set
  
  # load lookup table for activity label resolution
  activity_labels <- read.table(paste(c(rootDir, "/activity_labels.txt"), collapse = ""), col.names = c("activity.id", "activity.name"))
  # resolve activity names
  activities <- merge(activities, activity_labels, sort=FALSE)
  # drop useless activity.id column
  activities <- activities[,names(activities) != "activity.id"]
  
  # merge all datasets into one
  result <- cbind(subjects, activity.name = activities, measures)

  #### 4. Appropriately labels the data set with descriptive variable names.
  colnames(result) <- tidyVariableLabels(colnames(result))
  
  #### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
  stats <- computeStats(result)
  
  # return result
  return(stats)
}

# Formats and cleanup variable names extracted from feature.txt
#
# Args:
#   names: A vector containing the variable names to format.
#
# Returns:
#   The tidied name vector
tidyVariableLabels <- function(names) {

  # replace "-" with "."
  names <- gsub('\\-', '.', names)
  
  # remove "()"
  names <- gsub('\\(\\)', '', names)

  # split CamelCase into words
  names <- gsub("([A-Z])", ".\\1", names)

  # replace ".." with "."
  names <- gsub("\\.\\.", "\\.", names)
  
  # remove leading "f" or "t"
  names <- gsub('^[ft]\\.?', '', names)
  
  # return result
  return(names)
}


# Compute the average of each variable for each activity and each subject.
#
# Args:
#   data: A data frame created using createDataset
#   output: A string containing the name of the file to store data into. Default is NULL, meaning no file output
#
# Returns:
#   The computed data frame
computeStats <- function(data, output = NULL) {

  if(!require(reshape)) {
    stop("Failed to load required 'reshape' library")
  }
  
  # Build pivot table
  
  # 1. use subject.id and activity.name as rows identifiers (dimensions), other columns as variables (measures)
  stats <- melt(data, id = c('subject.id', 'activity.name'))
  
  # 2. aggregate values to compute average
  stats <- cast(stats, subject.id + activity.name ~ variable, mean)
  
  # Save results to output file
  if(!is.null(output)) {
    write.table(stats, file = output, row.name = FALSE)
  }
  
  # return result
  return(stats)
}
