#Check Project Folder#

    if(!file.exists("./data")){dir.create("./data")}

#Download and Unzip the Data#

    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

    unzip(zipfile="./data/Dataset.zip",exdir="./data")

    path <- file.path("./data" , "UCI HAR Dataset")

#Read Data#

    dataFeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
    dataFeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

    dataSubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
    dataSubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)

    dataActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt"),header = FALSE)
    dataActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"), header = FALSE)

    activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
    dataFeaturesNames <- read.table(file.path(path,"features.txt"),head=FALSE)

#Combine Pre-Datasets#

    dataFeatures <- rbind(dataFeaturesTest, dataFeaturesTrain)
    dataSubject <- rbind(dataSubjectTest, dataSubjectTrain)
    dataActivity <- rbind(dataActivityTest, dataActivityTrain)

#Name Pre-Datasets Elements#

    names(dataFeatures) <- dataFeaturesNames$V2
    names(dataSubject) <- c("subject")
    names(dataActivity) <- c("activity")

#Merge the total Dataset#

    data <- cbind(dataFeatures, dataSubject, dataActivity)

#Subset by "mean" and "standard deviation" variables#

    finalDataNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
    finalDataNames <- c(as.character(finalDataNames), "subject", "activity")

#Subset Only by Features containig Mean or Standard Deviation#

    finalData <- subset(data, select = finalDataNames)

#Factorize Activity and Subject Columns#

    finalData$activity <- factor(finalData$activity, levels = activityLabels$V1, labels = activityLabels$V1)
    finalData$subject <- as.factor(finalData$subject)
    levels(finalData$activity) <- levels(activityLabels$V2)

#Replace Column Names#

    names(finalData) <- gsub("^t", "time", names(finalData))
    names(finalData) <- gsub("^f", "frequency", names(finalData))
    names(finalData) <- gsub("Acc", "Accelerometer", names(finalData))
    names(finalData) <- gsub("Gyro", "Gyroscope", names(finalData))
    names(finalData) <- gsub("Mag", "Magnitude", names(finalData))
    names(finalData) <- gsub("BodyBody", "Body", names(finalData))

#Create second tidyData Set#

    secondData <- aggregate(.~subject + activity, finalData, mean)

    write.table(secondData, file = "secondData.txt", row.names = FALSE)
