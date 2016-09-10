# load library
library(reshape2)
library(bitops)
library(RCurl)

file <- "getdata_dataset.zip"
tidy1 <- "F:\\cursos_doctorado\\Getting and Cleaning Data\\proyecto\\FUCI HAR Dataset\\merge.txt"
tidy2 <- "F:\\cursos_doctorado\\Getting and Cleaning Data\\proyecto\\FUCI HAR Dataset\\tidy.txt"
# get data repos if this not exist
if (!file.exists(file)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

#read activities anda features
act <- read.table("UCI HAR Dataset/activity_labels.txt")
act[,2] <- as.character(act[,2])
feat <- read.table("UCI HAR Dataset/features.txt")
feat[,2] <- as.character(feat[,2])

#extract features mean and std
featmeanstd <- grep(".*mean.*|.*std.*", feat[,2])
featmeanstd.names <- feat[featmeanstd,2]

#get data trainer and subject_trainer
trainer <- read.table("UCI HAR Dataset/train/X_train.txt")[featmeanstd]
trainer_sub <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainer_act <- read.table("UCI HAR Dataset/train/Y_train.txt")

# build  dataset  with suject, activities of trainer
trainer <- cbind(trainer_sub, trainer_act, trainer)
write.table(trainer, tidy1, row.names = F)

#load test data
test_data <- read.table("UCI HAR Dataset/test/X_test.txt")[featmeanstd]
test_act <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_sub <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_data <- cbind(test_sub, test_act, test_data)

#build dataset with activities and subjects
ds <- rbind(trainer, test_data)
colnames(ds) <- c("subjects", "activities", featmeanstd.names)

#build factors activities and subjects
ds$activities <- factor(ds$activities, levels = act[,1], labels = act[,2])
ds$subjects <- as.factor(ds$subjects)

#get mean data
ds.melted <- melt(ds, id = c("subjects", "activities"))
ds.mean <- dcast(ds.melted, subjects + activities ~ variable, mean)
write.table(ds.mean, tidy2, row.names = FALSE, quote = FALSE)



