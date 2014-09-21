## Download UCI HAR Dataset archive, 
#  extract test and training datasets,
#  merge and process them making a tidy dataset.

## Download archived dataset
if(!file.exists("./data"))
{dir.create("./data")}

fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "UCI-HAR-Dataset.zip"

download.file(fileUrl, destfile=fileName)

#extract files from archive
unzip(fileName, exdir="data")

data_dir <- paste("./data","UCI HAR Dataset", sep="/")

## load labels
activityLabesFileName <- "activity_labels.txt"
activity_labels <- read.table(paste(data_dir, activityLabesFileName, sep="/"), col.names=c("labelcode","label"))

## load features
featuresFileName <- "features.txt"
features <- read.table(paste(data_dir, featuresFileName, sep="/"))

# Extract mean and standard deviation
extract_features <- grepl("mean|std", features[,2])

## load training set
training_folder <- paste(data_dir, "train", sep="/")
training_subject <- read.table(paste(training_folder, "subject_train.txt", sep="/"), 
                               col.names = "subject")
training_data <- read.table(paste(training_folder, "X_train.txt", sep="/"),
                            col.names = features[,2], check.names=FALSE)

# extract mean and standard deviation
training_data <- training_data[,extract_features]

training_labels <- read.table(paste(training_folder, "y_train.txt", sep="/"),
                              col.names = "labelcode")
training_df = cbind(training_labels, training_subject, training_data)

## load test set
test_folder <- paste(data_dir, "test", sep="/")
test_subject <- read.table(paste(test_folder, "subject_test.txt", sep="/"), 
                           col.names = "subject")
test_data <- read.table(paste(test_folder, "X_test.txt", sep="/"),
                        col.names = features[,2], check.names=FALSE)

# extract mean and standard deviation
test_data <- test_data[,extract_features]

test_labels <- read.table(paste(test_folder, "y_test.txt", sep="/"),
                          col.names = "labelcode")
test_df = cbind(test_labels, test_subject, test_data)

## merge datasets
merged_df <- rbind(training_df, test_df)

## replace label codes
merged_df = merge(activity_labels, merged_df, by.x="labelcode", by.y="labelcode")
merged_df <- merged_df[,-1]

## reshape dataframe
molten_df <- melt(merged_df, id = c("label", "subject"))

## make tidy dataset with mean of each variable 
tidy_df <- dcast(molten_df, label + subject ~ variable, mean)

## save tidy dataset to file
write.table(tidy_df, file="tidy_data.txt", quote=FALSE, row.names=FALSE, sep="\t")
