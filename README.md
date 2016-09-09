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

![Image of new variables](http://i67.tinypic.com/mct7x1.png)

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

1. Conduct Principle Component Analysis then z-scale: We chose the first two components to do z-scaling on. From the Scree plot below, we can see that the top two components can together explain the majority of the variation in the data. Then we did z-scaling on the scores of these two components. Then we tried Score = sum of z-scores and Score = average of z-scores, and they gave very similar results. We can only catch 2 fraud records in the top 10%.![Image of pca](http://i67.tinypic.com/n50wup.jpg)

2. Perform z-scaling on those 16 variables: This method does better than the previous one. We calculated the z-scores associated with the 16 variables. Here again, we experimented with different ways to score. We found that taking the weighted average of the top 4 z-scores generate the best result. The top 4 z-scores are determined by finding the highest z-score among the groups of 4 variables. Specifically, find the maximum values for number of transactions and amount of transaction in n days (N = 1, 2, 3, 7) on card number entity level and merchant number entity level. Then we took a weighted average of these four z-scores. The weights are:

<table>
  <tr>
    <th>card_scale_trans</th>
    <th>merch_scale_trans</th>
    <th>card_scale_amount</th>
    <th>merch_scale_amount</th>
  </tr>
  <tr>
    <td>0.2</td>
    <td>0.05</td>
    <td>0.7</td>
    <td>0.05</td>
  </tr>
</table>

The graph bellows show the top scores:

<table>
  <tr>
    <th>Record Number</th>
    <th>Fraud Score</th>
  </tr>
  <tr>
    <td>23911</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>23920</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>24313</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>24414</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>24451</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>24636</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>24660</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>25055</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>25265</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>25467</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>25570</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>25711</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>25716</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>25756</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>25850</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>25921</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>26426</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>27471</td>
    <td>3.90</td>
  </tr>
  <tr>
    <td>27510</td>
    <td>3.90</td>
  </tr>
</table>

Then we checked what percent of all fraud records can be caught by our model in the top 5% and top 10% records:

<table>
  <tr>
    <th></th>
    <th>Top 5%</th>
    <th>Top 10%</th>
  </tr>
  <tr>
    <td>Number of Fraud Caught</td>
    <td>137</td>
    <td>144</td>
  </tr>
  <tr>
    <td>% of all fraud</td>
    <td>67%</td>
    <td>70%</td>
  </tr>
</table>

Our model is quite robust as it captures 67% of all the fraud in the top 5% records. Later in the report, we will look into some of the top scores and explain why they are unusual. 

### High Score Analysis

Within fraud labeled 1~12, we caught 137 out of 206 in top 5% highest scores (about 4500 records), with most within the labels #1~#7.

We ranked the top 5% highest score records starting from 1 and did analysis on why they are fraudulent. Here are some records we think are typical of each kind of fraud that our algorithm find. Each table represent one fraud, including all original information, a score for each record and a corresponding rank. 

Some records that we included in our report are not in the top 5% (the score and rank cells are empty), but we still put it there because it can help us better understand why a particular record was labeled fraud by our algorithm. Since we use the past 90 days as our definition of normal, these records may help us understand how far away our target record is from normal, and possibly also the reason why the target record was labeled as fraud.

In our analysis below, we only interpreted records that had the highest fraud score (ranked as 1), and we grouped them by the type of fraud possible. Under each type of fraud, we grouped the suspicious records by the entity level that conveys more information, and analyzed each target record in context of date and entity.

***Fraud type: Large transaction amount in short amount of time***

Entity: CARDNUM

Explanation: this cardholder made 10 transactions in one day. The merchant is the same and the amount of each transaction is huge.

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
    <th>Fraud?</th>
    <th>Score</th>
    <th>Rank</th>
  </tr>
  <tr>
    <td>32569</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$3,640.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>32587</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$3,225.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>32591</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$2,250.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>32625</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$700.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>32667</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$14,625.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>32730</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$2,100.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>32765</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$2,100.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>32785</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$2,475.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>32815</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$2,156.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>32888</td>
    <td>5142288601</td>
    <td>5/4/2010</td>
    <td>460450006HRI6</td>
    <td>SENTINEL, INC.</td>
    <td>AL</td>
    <td>35801</td>
    <td>P</td>
    <td>$800.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
</table>

Entity: CARDNUM

Explanation: this cardholder made 4 transactions in a very short period of time. The merchant is the same and the amount of each transaction is huge and almost identical.

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
    <th>Fraud?</th>
    <th>Score</th>
    <th>Rank</th>
  </tr>
  <tr>
    <td>61425</td>
    <td>5142308889</td>
    <td>8/11/2010</td>
    <td>6054006890063</td>
    <td>BAR CODE DISCOUNT WAREHOU</td>
    <td>OH</td>
    <td>44133</td>
    <td>P</td>
    <td>$2,244.50</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>62204</td>
    <td>5142308889</td>
    <td>8/14/2010</td>
    <td>6054006890063</td>
    <td>BAR CODE DISCOUNT WAREHOU</td>
    <td>OH</td>
    <td>44133</td>
    <td>P</td>
    <td>$2,241.37</td>
    <td></td>
    <td>2.875472119</td>
    <td>394</td>
  </tr>
  <tr>
    <td>62681</td>
    <td>5142308889</td>
    <td>8/15/2010</td>
    <td>6054006890063</td>
    <td>BAR CODE DISCOUNT WAREHOU</td>
    <td>OH</td>
    <td>44133</td>
    <td>P</td>
    <td>$2,241.37</td>
    <td></td>
    <td>2.875472119</td>
    <td>394</td>
  </tr>
  <tr>
    <td>62855</td>
    <td>5142308889</td>
    <td>8/16/2010</td>
    <td>6054006890063</td>
    <td>BAR CODE DISCOUNT WAREHOU</td>
    <td>OH</td>
    <td>44133</td>
    <td>P</td>
    <td>$2,241.60</td>
    <td></td>
    <td>2.875472119</td>
    <td>394</td>
  </tr>
</table>

Entity: CARDNUM

Explanation: our algorithm captured 4 records of this cardholder so we just put it together. Transactions of large amount in a week.

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
    <th>Fraud?</th>
    <th>Score</th>
    <th>Rank</th>
  </tr>
  <tr>
    <th>32720</th>
    <th>5142182016</th>
    <th>5/4/2010</th>
    <th>7129011009306</th>
    <th>CBQ-NEWPORT #2</th>
    <th>RI</th>
    <th></th>
    <th>P</th>
    <th>$2,177.40</th>
    <th></th>
    <th>3.887340703</th>
    <th>1</th>
  </tr>
  <tr>
    <td>32842</td>
    <td>5142182016</td>
    <td>5/4/2010</td>
    <td>8006000808492</td>
    <td>CONWAY'S TOURS/GRAY LI</td>
    <td>RI</td>
    <td>02864</td>
    <td>P</td>
    <td>$575.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>34304</td>
    <td>5142182016</td>
    <td>5/10/2010</td>
    <td>89200600057</td>
    <td>ARAMARK HYNES CON</td>
    <td>MA</td>
    <td>02115</td>
    <td>P</td>
    <td>$6,116.01</td>
    <td></td>
    <td>2.894465643</td>
    <td>384</td>
  </tr>
  <tr>
    <td>41411</td>
    <td>5142182016</td>
    <td>6/5/2010</td>
    <td>7129011006606</td>
    <td>CBQ-NEWPORT #1</td>
    <td>RI</td>
    <td>02841</td>
    <td>P</td>
    <td>$262.40</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>50001</td>
    <td>5142182016</td>
    <td>7/5/2010</td>
    <td>8060633001300</td>
    <td>BOSTON PARK PLAZA HOTEL</td>
    <td>MA</td>
    <td>02116</td>
    <td>P</td>
    <td>$7,947.90</td>
    <td></td>
    <td>1.406695437</td>
    <td>2255</td>
  </tr>
</table>

Entity: CARDNUM

Explanation: this cardholder made 4 transactions in a very short period of time. The amount is huge. Also it is worth further analysis how this cardholder was able to made transactions in different states in 1 day (see record #71835, #72089). Is it online transactions or not?

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
    <th>Fraud?</th>
    <th>Score</th>
    <th>Rank</th>
  </tr>
  <tr>
    <td>70305</td>
    <td>5142310347</td>
    <td>9/8/2010</td>
    <td>4620006308197</td>
    <td>A-Z SALES &amp; SERVICE INC</td>
    <td>CO</td>
    <td>80524</td>
    <td>P</td>
    <td>$1,697.30</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>71249</td>
    <td>5142310347</td>
    <td>9/12/2010</td>
    <td>607990940336</td>
    <td>TOOL &amp; ANCHOR SUPPLY #2</td>
    <td>CO</td>
    <td>80204</td>
    <td>P</td>
    <td>$2,180.00</td>
    <td></td>
    <td>2.894465643</td>
    <td>384</td>
  </tr>
  <tr>
    <td>71835</td>
    <td>5142310347</td>
    <td>9/13/2010</td>
    <td>06-3666163370</td>
    <td>SWINTEC CORPORATION</td>
    <td>NJ</td>
    <td>07074</td>
    <td>P</td>
    <td>$1,696.32</td>
    <td></td>
    <td>2.894465643</td>
    <td>384</td>
  </tr>
  <tr>
    <td>72089</td>
    <td>5142310347</td>
    <td>9/13/2010</td>
    <td>604906862335</td>
    <td>INTERMTN SAFETY SHOES SR</td>
    <td>CO</td>
    <td>80907</td>
    <td>P</td>
    <td>$496.75</td>
    <td></td>
    <td>2.759679847</td>
    <td>469</td>
  </tr>
  <tr>
    <td>72345</td>
    <td>5142310347</td>
    <td>9/14/2010</td>
    <td>997536508333</td>
    <td>FIVE R REPAIR INC</td>
    <td>CO</td>
    <td>80401</td>
    <td>P</td>
    <td>$509.97</td>
    <td></td>
    <td>2.786916818</td>
    <td>445</td>
  </tr>
</table>

***Fraud type: Large transaction amount compare to other transactions***

Entity: CARDNUM

Explanation: this type of fraud is common in our captured records. They easily got high scores because the amount is huge compared to transactions before. In order to make it clearer, we kept all the records before high score transactions regardless they have scores or not.

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
    <th>Fraud?</th>
    <th>Score</th>
    <th>Rank</th>
  </tr>
  <tr>
    <td>2661</td>
    <td>5142186335</td>
    <td>1/13/2010</td>
    <td>465094667331</td>
    <td>AGILENT SAP</td>
    <td>GA</td>
    <td>30319</td>
    <td>P</td>
    <td>$299.78</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>3995</td>
    <td>5142186335</td>
    <td>1/19/2010</td>
    <td>465094667331</td>
    <td>AGILENT SAP</td>
    <td>GA</td>
    <td>30319</td>
    <td>P</td>
    <td>$163.00</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>6968</td>
    <td>5142186335</td>
    <td>2/1/2010</td>
    <td>900009091152</td>
    <td>BESSENBERG BINDERY CORP</td>
    <td>MI</td>
    <td>48104</td>
    <td>P</td>
    <td>$162.00</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>7132</td>
    <td>5142186335</td>
    <td>2/2/2010</td>
    <td>465094667331</td>
    <td>AGILENT SAP</td>
    <td>GA</td>
    <td>30319</td>
    <td>P</td>
    <td>$120.16</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>33376</td>
    <td>5142186335</td>
    <td>5/8/2010</td>
    <td>08-3508724258</td>
    <td>TOOL CRIB OF THE NORTH</td>
    <td>ND</td>
    <td>58201</td>
    <td>P</td>
    <td>$24.20</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>33642</td>
    <td>5142186335</td>
    <td>5/8/2010</td>
    <td>08-3508724258</td>
    <td>TOOL CRIB OF THE NORTH</td>
    <td>ND</td>
    <td>58201</td>
    <td>P</td>
    <td>$1,748.79</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>34278</td>
    <td>5142186335</td>
    <td>5/10/2010</td>
    <td>955666251221</td>
    <td>VALCU INSTRUMENTS</td>
    <td>TX</td>
    <td>77255</td>
    <td>P</td>
    <td>$141.85</td>
    <td></td>
    <td>3.211706018</td>
    <td>228</td>
  </tr>
</table>

<table>
  <tr>
    <th>40033</th>
    <th>5142125025</th>
    <th>5/31/2010</th>
    <th>1988500010006</th>
    <th>TROPICANA RESORT</th>
    <th>NV</th>
    <th>89109</th>
    <th>P</th>
    <th>$212.55</th>
    <th></th>
    <th></th>
    <th>2336</th>
  </tr>
  <tr>
    <td>40211</td>
    <td>5142125025</td>
    <td>5/31/2010</td>
    <td>1988500010006</td>
    <td>TROPICANA RESORT</td>
    <td>NV</td>
    <td>89109</td>
    <td>P</td>
    <td>$326.02</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>42682</td>
    <td>5142125025</td>
    <td>6/8/2010</td>
    <td></td>
    <td>RETAIL DEBIT ADJUSTMENT</td>
    <td></td>
    <td></td>
    <td>P</td>
    <td>$6,068.00</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>92769</td>
    <td>5142125025</td>
    <td>12/17/2010</td>
    <td>2094890001832</td>
    <td>S.R. COVEY LEADERSHIP CTR</td>
    <td>UT</td>
    <td>84606</td>
    <td>P</td>
    <td>$4,815.36</td>
    <td></td>
    <td>3.782707154</td>
    <td>28</td>
  </tr>
  <tr>
    <td>92849</td>
    <td>5142125025</td>
    <td>12/17/2010</td>
    <td>2094890001832</td>
    <td>S.R. COVEY LEADERSHIP CTR</td>
    <td>UT</td>
    <td>84606</td>
    <td>P</td>
    <td>$3,858.20</td>
    <td></td>
    <td>3.782707154</td>
    <td>28</td>
  </tr>
</table>

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
    <th>Fraud?</th>
    <th>Score</th>
    <th>Rank</th>
  </tr>
  <tr>
    <td>993</td>
    <td>5142186909</td>
    <td>1/6/2010</td>
    <td>9013200007658</td>
    <td>BIRCLAR ELECTRIC&amp;ELECTRIC</td>
    <td>MI</td>
    <td>48174</td>
    <td>P</td>
    <td>$2,045.00</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>22985</td>
    <td>5142186909</td>
    <td>3/30/2010</td>
    <td>9233400065101</td>
    <td>INTERNATIONAL LIBRARY</td>
    <td>UT</td>
    <td>84604</td>
    <td>P</td>
    <td>$68.60</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>23462</td>
    <td>5142186909</td>
    <td>3/31/2010</td>
    <td>991904849338</td>
    <td>AMER NATL STDS INST INC</td>
    <td>NY</td>
    <td>10036</td>
    <td>P</td>
    <td>$18.00</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>23976</td>
    <td>5142186909</td>
    <td>4/3/2010</td>
    <td>972610657332</td>
    <td>IEEE BOOK ORDERS</td>
    <td>NJ</td>
    <td>08855</td>
    <td>P</td>
    <td>$6.06</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>23995</td>
    <td>5142186909</td>
    <td>4/3/2010</td>
    <td>972610657332</td>
    <td>IEEE BOOK ORDERS</td>
    <td>NJ</td>
    <td>08855</td>
    <td>P</td>
    <td>$115.06</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>53763</td>
    <td>5142186909</td>
    <td>7/19/2010</td>
    <td>9013200007658</td>
    <td>BIRCLAR ELECTRIC&amp;ELECTRIC</td>
    <td>MI</td>
    <td>48174</td>
    <td>P</td>
    <td>$2,045.00</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
</table>

***Fraud type: Suspicious merchant***

Entity: MERCHNUM

Explanation: This merchant has multiple merchant number, in the same zip code. Transactions made in a short period of time with high amount by a single cardholder, which is also suspicious.

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
    <th>Fraud?</th>
    <th>Score</th>
    <th>Rank</th>
  </tr>
  <tr>
    <td>52696</td>
    <td>5142295584</td>
    <td>7/14/2010</td>
    <td>330400610006</td>
    <td>OMNI INNER HARBOR</td>
    <td>MD</td>
    <td>21201</td>
    <td>P</td>
    <td>$3,836.25</td>
    <td></td>
    <td>3.887340703</td>
    <td>1</td>
  </tr>
  <tr>
    <td>55636</td>
    <td>5142295584</td>
    <td>7/25/2010</td>
    <td>330400615555</td>
    <td>OMNI INNER HARBOR</td>
    <td>MD</td>
    <td>21201</td>
    <td>P</td>
    <td>$6,294.00</td>
    <td></td>
    <td>2.102439357</td>
    <td>1043</td>
  </tr>
  <tr>
    <td>34023</td>
    <td>5142149691</td>
    <td>5/10/2010</td>
    <td>330400610031</td>
    <td>OMNI INNER HARBOR</td>
    <td>MD</td>
    <td>21201</td>
    <td>P</td>
    <td>$336.00</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>55015</td>
    <td>5142295584</td>
    <td>7/22/2010</td>
    <td>330400610006</td>
    <td>OMNI INNER HARBOR</td>
    <td>MD</td>
    <td>21201</td>
    <td>P</td>
    <td>$48.36</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>55067</td>
    <td>5142295584</td>
    <td>7/22/2010</td>
    <td>330400615555</td>
    <td>OMNI INNER HARBOR</td>
    <td>MD</td>
    <td>21201</td>
    <td>P</td>
    <td>$495.00</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
  <tr>
    <td>57087</td>
    <td>5142295584</td>
    <td>7/29/2010</td>
    <td>330400610033</td>
    <td>OMNI INNER HARBOR</td>
    <td>MD</td>
    <td>21201</td>
    <td>P</td>
    <td>$123.75</td>
    <td></td>
    <td></td>
    <td>2336</td>
  </tr>
</table>
