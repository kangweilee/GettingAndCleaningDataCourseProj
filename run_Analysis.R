library(data.table)
filelocation = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./UCI HAR Dataset.zip')){
  download.file(filelocation,'./HAR Dataset.zip', mode = 'wb')
  unzip("HAR Dataset.zip", exdir = getwd())
}


# Merges the training and the test sets to create one data set
# Read csv file into f and convert into a single data frame

f <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
f <- as.character(f[,2])


d.t.x <- read.table('./UCI HAR Dataset/train/X_train.txt')
d.t.activity <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
d.t.subject <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

d.train <-  data.frame(d.t.subject, d.t.activity, d.t.x)
names(d.train) <- c(c('subject', 'activity'), f)

d.test.x <- read.table('./UCI HAR Dataset/test/X_test.txt')
d.test.activity <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
d.test.subject <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

d.test <-  data.frame(d.test.subject, d.test.activity, d.test.x)
names(d.test) <- c(c('subject', 'activity'), f)

## 1.  Merge the train and test dataset together to "d.all"
d.all <- rbind(d.train, d.test)

## 2.  Get mean and standard deveiation
mean_std.select <- grep('mean|std', f)
d.sub <- d.all[,c(1,2,mean_std.select + 2)]

##3. Read labels from activity_labels.text to name activities
activity.labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activity.labels <- as.character(activity.labels[,2])
d.sub$activity <- activity.labels[d.sub$activity]


##4.  Rename names name.new with descriptive names
name.new <- names(d.sub)



name.new <- gsub("^t", "Time_", name.new)
name.new <- gsub("^f", "Frequency_", name.new)

name.new <- gsub("-mean-", "_Mean_", name.new)
name.new <- gsub("-std-", "_StandardDeviation_", name.new)

name.new <- gsub("Gyro", "Gyroscope", name.new)
name.new <- gsub("Acc", "Accelerometer", name.new)
name.new <- gsub("Mag", "Magnitude", name.new)


name.new <- gsub("[(][)]", "", name.new)
name.new <- gsub("-", "_", name.new)

names(d.sub) <- name.new


##4.  Output data to d_tidy.txt.  From previous data set
##    with the average 
d.tidy <- aggregate(d.sub[,3:81], by = list(activity = d.sub$activity, subject = d.sub$subject),FUN = mean)
write.table(x = d.tidy, file = "d_tidy.txt", row.names = FALSE)

