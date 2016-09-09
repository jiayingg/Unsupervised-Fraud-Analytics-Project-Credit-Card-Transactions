# Unsupervised Fraud Analytics Project: Credit Card Transactions

>Corporate Card Transaction Data is dataset recorded 95,272 credit card transactions made during the year of 2010. For each transaction record, there’s detailed information of card number, transaction date, merchant number, merchant state and zip, etc. Among these 95,272 transactions, there are 206 transactions that are fraudulent. 

>For example, **Fraud Type 1** transactions are using the same card, with the same merchant, over 2 days. **Fraud Type 2** transactions are with the same merchant across many cards in 5 days, also with usual high dollar amounts. 

>Through unsupervised learning method, our ultimate goal is to catch as many transactions with the fraud label as possible by building models to compute a fraud score for each record. The labeled frauds are not used in our model but are used to check the robustness of the model.

### Contributors

- Jiaying Gu
- Jessie Yu
- Siyu Zhang
- Ruoyu Sun
- Isabelle Zhao

### Executive Summary

We started the project by conducting data quality report on the dataset, briefly explored the dataset and found interesting and unusual things about the data. After understanding what the data is about, we began to build variables and prepared the variables for model construction. When choosing entity levels, we decided that card number (CARDNUM) and merchant number (MERCHNUM) are proper because basically they help explain behavior variation in our data. Since we want to study the transaction behavior, two things we focus on are the number of transactions and the amount of transaction. The variables we built are number of transactions in past N (N = 1,2,3,7) days and amount of transactions in past N (N = 1,2,3,7) days based on CARDNUM and MERCHNUM entity levels, and standardize them by the dividing the corresponding activities in the past 90 days. This gives us a total of 16 calculated variables. Setting the first 90 days as baseline, we are only able to score the transactions starting from April 1. We experimented several scoring methods, the method of z-scaling the variables and taking the weighted average of the highest z-scores gives us the best result, which catches 67% of the fraud transactions in our top 5% scored records and 70% of the fraud transactions in our top 10% scored records. 

At the end of the report, we will discuss the fraud transactions that have been caught through our model and the high fraud score transactions in detail.

### Summary of Data

The data contains credit card transaction records, along with the card number, merchant information, and transaction date and type. There is a total of 95,271 records (We excluded the one record related to Mexico with a suspiciously high transaction amount, the detail record is listed below) with 10 fields (1 unique identifier, 1 dependent variable, 8 independent variables). For each record, fraud label of “1” means that the record is fraud and “0” means that the record is nonfraud. In the data set, the percentage of records with “Fraud label” =1 approximately equals to 4.2%. The timeframe was from 1/1/2010 to 12/31/2010 and the original format is .csv file. Below is a summary of the field names and the percent populated in each field.

<table>
  <tr>
    <th></th>
    <th>Field Name</th>
    <th>% Populated</th>
  </tr>
  <tr>
    <td>Dependent variable</td>
    <td>FRAUD LABEL</td>
    <td>100%</td>
  </tr>
  <tr>
    <td>Numerical Independent variables</td>
    <td>AMOUNT</td>
    <td>100%</td>
  </tr>
  <tr>
    <td rowspan="7">Categorical Independent variables</td>
    <td>CARDNUM</td>
    <td>100%</td>
  </tr>
  <tr>
    <td>MERCHNUM</td>
    <td>96%</td>
  </tr>
  <tr>
    <td>MERCHDESCRIPTION</td>
    <td>100%</td>
  </tr>
  <tr>
    <td>MERCHSTATE</td>
    <td>99%</td>
  </tr>
  <tr>
    <td>TRANSTYPE</td>
    <td>100%</td>
  </tr>
  <tr>
    <td>MERCHZIP</td>
    <td>95%</td>
  </tr>
  <tr>
    <td>DATE</td>
    <td>100%</td>
  </tr>
</table>

From our basic exploration of the data, a few findings may help guide further analysis:

- The number of transactions associated with each card number varies greatly, with largest number over 1,000. The number of transactions for each merchant also varies greatly, with largest number over 9,000. It might be interesting to explore the high values within these two entities.

- The zip code with each merchant has the highest number of missing values. The zip codes listed also have different length and formats. Due to the unexplainable irregularity in this field, we might not choose it as an entity for our analysis.

- This is the largest amount of payment in the dataset, and has a significantly higher value than other records. There are many missing information in this row and the information of Merchant description which is “INTERMEXICO” is very suspicious associated with this payment amount. The existence of this record might have an influence on our scoring of other records.
<table>
  <tr>
    <th>Record #</th>
    <th>CARDNUM</th>
    <th>DATE</th>
    <th>MERCHNUM</th>
    <th>MERCHDESCRIPTION</th>
    <th>MERCHSTATE</th>
    <th>MERCHZIP</th>
    <th>TRANSTYPE</th>
    <th>AMOUNT</th>
  </tr>
  <tr>
    <td>52293</td>
    <td>5142189135</td>
    <td>7/13/2010</td>
    <td></td>
    <td>INTERMEXICO</td>
    <td></td>
    <td></td>
    <td>P</td>
    <td>$3,102,045.53</td>
  </tr>
</table>

### Entities and Variables

- Entities

We considered dividing the data based on two entity levels: CARDNUM and MERCHNUM. Observing anomalies on these two entity levels may help account for the user differences among different card holders and different merchants.

- Variables:

We added a total of 16 variables to model our data. Our intention is to find anomalies based on the number of transactions and the total transaction amount during a time frame. We calculated each variable on its entity level. Due to the usual patterns of credit card fraud, we selected the time frame to be in the past 1, 2, 3, or 7 days. Since we are assuming that we have no knowledge of records that happened after each existing record, we standardized the variable by setting the activity on each entity level in the past 90 days as normal.

As we define fraud as those records who have an unusually high score, we set all negative values in the variables to be 0. We also removed records that are within the first 90 days, from 1/1/2010 to 3/31/2010, from our ranking, since these records do not have a 90 day history that we are using for standardization. If the 90 day history of a record is 0, which cannot be divided, we set the variable for that record to be 1, the assumed normal value.

We excluded the record with the highest transaction amount, to prevent it from influencing our analysis.

Below are our variables:

    card_scale_trans_N=(90/N)∙(Number of transactions in the past N days on this card)/(Number of transactions in the past 90 days on this card), For N = 1, 2, 3, 7
    card_scale_amount_N=(90/N)∙( Total transaction amount in the past N days on this card)/( Total transaction amount in the past 90 days on this card), For N = 1, 2, 3, 7
    merch_scale_trans_N=(90/N)∙(Number of transactions in the past N days from merchant)/(Number of transactions in the past 90 days from merchant), For N = 1, 2, 3, 7
    merch_scale_amount_N=(90/N)∙( Total trans amount in the past N days from merchant)/( Total trans amount in the past 90 days from merchant), For N = 1, 2, 3, 7

### Model Algorithm

After creating the 16 variables as mentioned above, we experimented with two types of scoring algorithms: 

1. Conduct Principle Component Analysis and choose top components that together contribute roughly 70% to 80% of the variation. Then perform z-scaling on the top components. To calculate the fraud score, we tried different approaches:
    a) Score = sum of z-scores
    b) Score = average of z-scores 

2. Perform z-scaling on those 16 variables. Consequently, we have 16 groups of z-scores. We explored three ways of calculating fraud score: 
    a) Score = sum of all z-scores
    b) Score = average of all z-scores
    c) Score = weighted average of the top 4 z-scores (one for each N). For example, find the highest z-score among the groups of 4 variables for number of transactions in n days (N = 1, 2, 3, 7). Do the same for other three groups. 

In both approaches, we make sure that we are only looking at the positive z-scores when calculating the final fraud score. The reason is that in this project, we are mainly interested in finding cases where the card is lost or stolen, or a bad merchant gets the card. In theses cases, records tend to have higher-than-usual amount or number of transactions in a given period. Therefore, we transformed all negative z-scores into zero to only focus on positive deviations. 

In addition, we did not score the first 3 months of the records. The fraud algorithms need to “mature” before they can do a good job in finding frauds. We chose 90 days as a training period so that the algorithms can get a good sense of what is normal behavior for each card number or merchant. We experimented with scoring all records, and the result was not as good as eliminating the first 90 days of records. 

We found out that the second approach with Score = weighted average of the top 4 z-scores (one for each N) gives the best result. Detailed result will be presented later in the report. 

### Model Result:

As mentioned in Model Algorithm, we experimented with two different approaches as well as a number of ways to compute the final fraud score. We will briefly talk about the result of these algorithms and focus on the one that we decided to implement. 

1. Conduct Principle Component Analysis then z-scale

We chose the first two components to do z-scaling on. From the Scree plot below, we can see that the top two components can together explain the majority of the variation in the data. Then we did z-scaling on the scores of these two components. Then we tried Score = sum of z-scores and Score = average of z-scores, and they gave very similar results. We can only catch 2 fraud records in the top 10%.

![Image of pca](http://i67.tinypic.com/n50wup.jpg)

2. Perform z-scaling on those 16 variables

This method does better than the previous one. We calculated the z-scores associated with the 16 variables. Here again, we experimented with different ways to score. We found that taking the weighted average of the top 4 z-scores generate the best result. The top 4 z-scores are determined by finding the highest z-score among the groups of 4 variables. Specifically, find the maximum values for number of transactions and amount of transaction in n days (N = 1, 2, 3, 7) on card number entity level and merchant number entity level. Then we took a weighted average of these four z-scores. The weights are:

