# set working directory to current script file location 
# and create data directory if it does not exist

mainDir <- dirname(sys.frame(1)$ofile)
dataDir <- "data"
setwd(mainDir)

if (!file.exists(dataDir)){
    message("Creating data directory.")
    dir.create(file.path(mainDir, dataDir))
} else {
    message("Data directory exists.")
}

# check if data file downloaded, download if not

if (!file.exists("./data/data.zip")){
    message("Downloading data file....")
    fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    download.file(fileUrl, destfile = "./data/data.zip")
} else {
    message("Data file already exists.")
}

# Unzip downloaded data

if (!file.exists("./data/Source_Classification_Code.rds") | !file.exists("./data/summarySCC_PM25.rds")){
    message("Unzipping data file.....")
    unzip("./data/data.zip", exdir = file.path(mainDir, dataDir))
} else {
    message("Data already unzipped.")
}

# read data

message("Reading data from source files... it will take some time so be patient!")

NEI <- readRDS("./data/summarySCC_PM25.rds")
SCC <- readRDS("./data/Source_Classification_Code.rds")

# which source classification short names include word "coal", assume those are the right/expected codes, extract respective emissions from NEI

coalCodes <- grep("coal", SCC$Short.Name, ignore.case = TRUE)
coalCodes <- SCC[coalCodes, ]
coalData <- NEI[NEI$SCC %in% coalCodes$SCC, ]

# check plotting directory, if necessary create it and create coal emissions plot in it

if (!file.exists("plots")){
    message("Creating plotting directory.")
    dir.create(file.path(mainDir, "plots"))
} else {
    message("Plotting directory exists.")
}

png(filename = "./plots/plot4.png", width = 480, height = 480, units = "px")


coalEmissions <- aggregate(coalData$Emissions, list(coalData$year), FUN = "sum")
plot(coalEmissions, type = "l", xlab = "Year", main = "Total Coal-related Emissions in the US (1999-2008)", 
     ylab = "Emissions")
dev.off()

message("Done! Check ./plots/ directory to find plot4.png file")