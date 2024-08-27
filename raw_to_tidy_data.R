# importing libraries
library(jsonlite)
library(dplyr)
library(lubridate)

# downloading the raw data
if (!dir.exists('data/raw_data')) dir.create('data/raw_data/', recursive = TRUE)
## 1 day time frame
download.file("https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/chart?id=1&range=1D",
              "data/raw_data/prices_of_btc_usd_1DTimeframe.json")
## 7 day time frame
download.file("https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/chart?id=1&range=7D",
              "data/raw_data/prices_of_btc_usd_7DTimeframe.json")
## 1 month time frame
download.file("https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/chart?id=1&range=1M",
              "data/raw_data/prices_of_btc_usd_1MTimeframe.json")
## 1 year time frame
download.file("https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/chart?id=1&range=1Y",
              "data/raw_data/prices_of_btc_usd_1YTimeframe.json")
## ALL
download.file("https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/chart?id=1&range=ALL",
              "data/raw_data/prices_of_btc_usd_ALLTimeframe.json")
time_of_download <- now()
#https://coinmarketcap.com/currencies/bitcoin/



# parsing json file of BTC/USD
btc_usd_price_1D <- fromJSON('data/raw_data/prices_of_btc_usd_1DTimeframe.json')[[c(1, 1)]]
btc_usd_price_7D <- fromJSON('data/raw_data/prices_of_btc_usd_7DTimeframe.json')[[c(1, 1)]]
btc_usd_price_1M <- fromJSON('data/raw_data/prices_of_btc_usd_1MTimeframe.json')[[c(1, 1)]]
btc_usd_price_1Y <- fromJSON('data/raw_data/prices_of_btc_usd_1YTimeframe.json')[[c(1, 1)]]
btc_usd_price_ALL <- fromJSON('data/raw_data/prices_of_btc_usd_ALLTimeframe.json')[[c(1, 1)]]


# turning data to dataframe
## adding time
### 1D
times_1D <- as.POSIXct(as.integer(names(btc_usd_price_1D)))
times_1D <- as.POSIXlt(times_1D)
btc_df_1D <- data.frame(time = times_1D)

### 7D
times_7D <- as.POSIXct(as.integer(names(btc_usd_price_7D)))
times_7D <- as.POSIXlt(times_7D)
btc_df_7D <- data.frame(time = times_7D)

### 1M
times_1M <- as.POSIXct(as.integer(names(btc_usd_price_1M)))
times_1M <- as.POSIXlt(times_1M)
btc_df_1M <- data.frame(time = times_1M)

### 1Y
times_1Y <- as.POSIXct(as.integer(names(btc_usd_price_1Y)))
times_1Y <- as.POSIXlt(times_1Y)
btc_df_1Y <- data.frame(time = times_1Y)

### ALL
times_ALL <- as.POSIXct(as.integer(names(btc_usd_price_ALL)))
times_ALL <- as.POSIXlt(times_ALL)
btc_df_ALL <- data.frame(time = times_ALL)

### removing unnecessary variables from R environment
rm(times_1D, times_7D, times_1M, times_1Y, times_ALL)


## adding prices to data frame
### 1D
prices_btc_usd_1D <- sapply(btc_usd_price_1D, function(point){
      point$v[[1]]
})
btc_df_1D$price_in_usd <- prices_btc_usd_1D
btc_df_1D$timeframe <- '1D' ## adding time frame

### 7D
prices_btc_usd_7D <- sapply(btc_usd_price_7D, function(point){
      point$v[[1]]
})
btc_df_7D$price_in_usd <- prices_btc_usd_7D
btc_df_7D$timeframe <- '7D' ## adding time frame

### 1M
prices_btc_usd_1M <- sapply(btc_usd_price_1M, function(point){
      point$v[[1]]
})
btc_df_1M$price_in_usd <- prices_btc_usd_1M
btc_df_1M$timeframe <- '1M' ## adding time frame

### 1Y
prices_btc_usd_1Y <- sapply(btc_usd_price_1Y, function(point){
      point$v[[1]]
})
btc_df_1Y$price_in_usd <- prices_btc_usd_1Y
btc_df_1Y$timeframe <- '1Y' ## adding time frame

### ALL
prices_btc_usd_ALL <- sapply(btc_usd_price_ALL, function(point){
      point$v[[1]]
})
btc_df_ALL$price_in_usd <- prices_btc_usd_ALL
btc_df_ALL$timeframe <- 'ALL' ## adding time frame

### removing unnecessary variables from R environment
rm(prices_btc_usd_1D, prices_btc_usd_7D, prices_btc_usd_1M, prices_btc_usd_1Y, prices_btc_usd_ALL)
rm(btc_usd_price_1D, btc_usd_price_7D, btc_usd_price_1M, btc_usd_price_1Y, btc_usd_price_ALL)


## concating all time frames
btc_df <- rbind(btc_df_1D, btc_df_7D, btc_df_1M, btc_df_1Y, btc_df_ALL)
### removing unnecessary variables from R environment
rm(btc_df_1D, btc_df_7D, btc_df_1M, btc_df_1Y, btc_df_ALL)


## using dplyr package for more convenience
btc_df <- as_tibble(btc_df)

## rearranging columns
btc_df <- btc_df %>% select(timeframe, time, price_in_usd)

## making timeframe column a factor
btc_df$timeframe <- factor(btc_df$timeframe)

## sorting rows based on timeframe and time with increasing time frame and decreasing time
btc_df <- btc_df %>% arrange(timeframe, desc(time))



# saving btc_df as object
if (!dir.exists('data/tidy_data/')) dir.create('data/tidy_data/', recursive = TRUE)
dput(btc_df, file = "data/tidy_data/btc_df.R")

# saving tidy dataset as a table
## changing time variable so it doesnt have space in between when written to file
btc_df$time <- as.character(btc_df$time)
btc_df$time <- sub(" ", replacement = "_", x = btc_df$time)

write.table(btc_df, file = 'data/tidy_data/btc.txt', row.names = FALSE)

# adding time of download as a text file
time_log <- file("data/raw_data/time_of_download.txt", "w")
writeLines(as.character(time_of_download), time_log)
close(time_log)

rm(btc_df, time_log, time_of_download)
