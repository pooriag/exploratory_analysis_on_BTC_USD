# importing libraries
library(jsonlite)
library(dplyr)
library(ggplot2)

# downloading the raw data
if (!dir.exists('data')) dir.create('data/')

download.file("https://api.coinmarketcap.com/data-api/v3/cryptocurrency/detail/chart?id=1&range=1D",
              "data/prices_of_btc_usd.json")
#https://coinmarketcap.com/currencies/bitcoin/

# parsing json file of BTC/USD
btc_usd_price <- fromJSON('data/prices_of_btc_usd.json')[[c(1, 1)]]

# turning data to dataframe
times <- as.POSIXct(as.integer(names(btc_usd_price)))
times <- as.POSIXlt(times)
btc_df <- data.frame(time = times)

## using dplyr package for more convinience
btc_df <- as_tibble(btc_df)

## adding prices to data frame
prices_btc_usd <- sapply(btc_usd_price, function(point){
      point$v[[1]]
})
btc_df$price_in_usd <- prices_btc_usd

qplot(btc_df$time, btc_df$price_in_usd, geom = 'line')

