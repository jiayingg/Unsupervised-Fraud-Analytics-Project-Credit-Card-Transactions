library(dplyr)
library(lubridate)

data = read.csv("creditcardfraud.csv", header = T)

data$DATE = mdy(data$DATE)

data$past1day = data$DATE
data$past90day = data$DATE + days(-89)
data$past2day = data$DATE + days(-1)
data$past3day = data$DATE + days(-2)
data$past7day = data$DATE + days(-6)


### Transaction in past N day
### Transaction in past 90 day

for(i in 1:dim(data)[1])
{
  data$card_trans1day[i] = nrow(filter(data,
                                  CARDNUM == CARDNUM[i] &
                                    DATE <= DATE[i] &
                                    DATE >= past1day[i]))
  data$card_trans2day[i] = nrow(filter(data,
                                  CARDNUM == CARDNUM[i] &
                                    DATE <= DATE[i] &
                                    DATE >= past2day[i]))
  data$card_trans3day[i] = nrow(filter(data,
                                  CARDNUM == CARDNUM[i] &
                                    DATE <= DATE[i] &
                                    DATE >= past3day[i]))

  data$card_trans7day[i] = nrow(filter(data,
                                  CARDNUM == CARDNUM[i] &
                                    DATE <= DATE[i] &
                                    DATE >= past7day[i]))
  data$card_trans90day[i]= nrow(filter(data,
                                  CARDNUM == CARDNUM[i] &
                                    DATE <= DATE[i] &
                                    DATE >= past90day[i]))
  data$merch_trans1day[i] = nrow(filter(data,
                                       MERCHNUM == MERCHNUM[i] &
                                         DATE <= DATE[i] &
                                         DATE >= past1day[i]))
  data$merch_trans2day[i] = nrow(filter(data,
                                       MERCHNUM == MERCHNUM[i] &
                                         DATE <= DATE[i] &
                                         DATE >= past2day[i]))
  data$merch_trans3day[i] = nrow(filter(data,
                                       MERCHNUM == MERCHNUM[i] &
                                         DATE <= DATE[i] &
                                         DATE >= past3day[i]))
  
  data$merch_trans7day[i] = nrow(filter(data,
                                       MERCHNUM == MERCHNUM[i] &
                                         DATE <= DATE[i] &
                                         DATE >= past7day[i]))
  data$merch_trans90day[i]= nrow(filter(data,
                                       MERCHNUM == MERCHNUM[i] &
                                         DATE <= DATE[i] &
                                         DATE >= past90day[i]))
}

data$card_scale_trans_1 = (90/1)*data$card_trans1day/data$card_trans90day
data$card_scale_trans_2 = (90/2)*data$card_trans2day/data$card_trans90day
data$card_scale_trans_3 = (90/3)*data$card_trans3day/data$card_trans90day
data$card_scale_trans_7 = (90/7)*data$card_trans7day/data$card_trans90day

data$merch_scale_trans_1 = (90/1)*data$merch_trans1day/data$merch_trans90day
data$merch_scale_trans_2 = (90/2)*data$merch_trans2day/data$merch_trans90day
data$merch_scale_trans_3 = (90/3)*data$merch_trans3day/data$merch_trans90day
data$merch_scale_trans_7 = (90/7)*data$merch_trans7day/data$merch_trans90day


save(data, file = "TransData.Rda")
