---
tags: R
---

<meta name="twitter:site" content="@josiahparry">
<meta name="twitter:creator" content="@josiahparry">
<meta name="twitter:image" content="http://josiahparry.com/images/favicon.png">
<meta name="twitter:text:title" content="Josiah Parry: Sparklyr Exploration">
<meta name="twitter:text:description" content="This document will explore some of the basic machine learning functions of MLlib interface in the new package *sparklyr* from **RStudio** that was just announced yesterday (6/29/16) at the *useR* conference!">

# sparklyr Exploration: Kmeans, Linear & Logistic Regression

This document will explore some of the basic machine learning functions of MLlib interface in the new package *sparklyr* from **RStudio** that was just announced yesterday (6/29/16) at the *useR* conference! The *sparklyr* package also provides for an interface to use *dplyr* as well.
 <!--split-->

### Installing and preparing sparklyr

The following lines of code will install *sparklyr* and the lastest version of spark. sparklyr works with a full integration of the *dplyr* package.


```r
#load sparklyr & dplyr
devtools::install_github("rstudio/sparklyr")
library(sparklyr)
library(dplyr)

# install spark
spark_install(version = "1.6.2")
# Connecting to spark using spark_connect, on a local connection.
sc <- spark_connect(master = "local")
```

### Linear Regression

This will be an example of using Spark's linear regression model on the classic wine quality data set. The code will compare the output from *sparklyr* and the base R `lm()` function.

This regression will try to predict wine quality based on its pH, alcohol, density, and wine type.


```r
# Loading local data
wine <- read.csv("wine_classification.csv")
# The copy_to function copys the local data frame to a spark data table
wine_tbl <- copy_to(sc, wine)

# Set a seed
set.seed(0)
```

Let's first create our model using Spark's linear regression.


```r
fit <- wine_tbl %>% ml_linear_regression(response = "quality",
                                         features = c("pH", "alcohol", "density", "type"))
```
Note that this throws an error *"... does not support the StringType type..."*. In order to fit the regression model we need to conver `type` into binary using dummy variable. Since there are only 2 factor levels, we only need 1 dummy variable. I will do this using *dplyr* and an ifelse statement.


```r
# Note that spark doesn't like strings. I'm converting the quality to a dummy variable where white = 1
wine_tbl <- wine_tbl %>% mutate(white = ifelse(type == "White", 1, 0))
```
There is now a new variable called `white`, this will be used in place of `type`. When `white` equals `0` the wine is red.

```r
# Creating model using sparklyr with new dummy variable
fit <- wine_tbl %>% ml_linear_regression(response = "quality",
                                         features = c("pH", "alcohol", "density", "white"))
```
Now that we have created a working linear regression model usin Spark, lets create the same model using the base R function `lm()`.


```r
# creating lm using base functions
fit_base <- lm(quality ~ pH + alcohol + density + white, data = wine_tbl)
```
Now its time to compare the output of these models.


```r
#compare models
summary(fit)
summary(fit_base)
```


```r
Call:
quality ~ pH + alcohol + density + white

Residuals:
     Min       1Q   Median       3Q      Max
-3.09370 -0.50118  0.02525  0.50473  3.48359

Coefficients:
               Estimate  Std. Error  t value  Pr(>|t|)
(Intercept)  30.2243682   5.5927285   5.4042 6.811e-08 ***
pH           -0.0083494   0.0724080  -0.1153    0.9082
alcohol      -0.3607972   0.0130215 -27.7077 < 2.2e-16 ***
density     -22.1625961   5.4908946  -4.0362 5.513e-05 ***
white        -0.2221567   0.0335749  -6.6168 4.057e-11 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

R-Squared: 0.2119
Root Mean Squared Error: 0.7732

Call:
lm(formula = quality ~ pH + alcohol + density + white, data = wine_tbl)

Residuals:
    Min      1Q  Median      3Q     Max
-3.0937 -0.5012  0.0253  0.5047  3.4836

Coefficients:
              Estimate Std. Error t value Pr(>|t|)
(Intercept)  30.224368   5.592729   5.404 6.81e-08 ***
pH           -0.008349   0.072408  -0.115    0.908
alcohol      -0.360797   0.013022 -27.708  < 2e-16 ***
density     -22.162596   5.490895  -4.036 5.51e-05 ***
white        -0.222157   0.033575  -6.617 4.06e-11 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 0.7736 on 4995 degrees of freedom
Multiple R-squared:  0.2119,	Adjusted R-squared:  0.2113
F-statistic: 335.8 on 4 and 4995 DF,  p-value: < 2.2e-16
```

### K-Means Clustering

Now I will display how to create a k-means clustering algorithm using the same wine data set and the same response, and predictor variables.

Since I can't use the spark tbl I will create the same data as a regular dplyr table and create a k-means cluster with three centroids, with a maximum of 10 iteratiosn.


```r
wine <- wine %>% mutate(white = ifelse(type == "White", 1, 0))

# Create k-means using base
base_kmeans <- kmeans(wine[, c("quality", "pH", "alcohol", "density", "white")], 3, iter.max = 10)
```
Now that we have created our base k-mean clusters, lets see how they compare to the Spark k-means function.


```r
# Create k-means using spark
spark_kmeans <-  wine_tbl %>% ml_kmeans(centers = 3, iter.max = 10,
                                 features = c("quality", "pH", "alcohol", "density", "white"))
```

Now that we have our models, lets compare their outputs.


```r
# Time to compare the centers
# creating data frame from kmeans centers
base_centers <- data.frame(base_kmeans$centers)

# Printing centers of base and spark
arrange(base_centers, quality)
arrange(spark_kmeans$centers, quality)
```

```r
arrange(base_centers, quality)

   quality       pH   alcohol   density     white
1 3.315789 3.214880 12.313013 0.9925428 0.8713450
2 4.028708 3.230960 10.757488 0.9949527 0.8337321
3 4.656820 3.193401  9.447361 0.9974843 0.7810599

arrange(spark_kmeans$centers, quality)

   quality       pH   alcohol   density     white
1 3.325832 3.215063 12.321054 0.9925308 0.8718200
2 4.007860 3.229656 10.760423 0.9949429 0.8367594
3 4.660069 3.194576  9.456816 0.9974685 0.7792599
```

The differences in the centers are quite minimal, perhaps due to randomness or differences in rounding.

### Logistic Regression

For this demonstration I will use the same data set that is used in the **Intro to Credit Risk Modeling in R** from **DataCamp**. The course uses logistic regression to predict default rates. We will create a similar model using the base `glm()` function, and the MLlib logit model function `ml_logistic_regression()`.

The model I will create will predict loan status, based on the loan ammount, age of borrower, and their employment duration. Loan status is binary where **1** is a default and **0** is a non-default.

Now lets load our data:

```r
# load the data
loan_data <- readRDS("loan_data.rds")
loan_data_tbl <- copy_to(sc, loan_data) # copying it to spark
```
Printed are the first 10 rows.

```r
 loan_status loan_amnt int_rate grade emp_length home_ownership annual_inc   age
         <int>     <int>    <dbl> <chr>      <int>          <chr>      <dbl> <int>
1            0      5000    10.65     B         10           RENT      24000    33
2            0      2400       NA     C         25           RENT      12252    31
3            0     10000    13.49     C         13           RENT      49200    24
4            0      5000       NA     A          3           RENT      36000    39
5            0      3000       NA     E          9           RENT      48000    24
6            0     12000    12.69     B         11            OWN      75000    28
7            1      9000    13.49     C          0           RENT      30000    22
8            0      3000     9.91     B          3           RENT      15000    22
9            1     10000    10.65     B          3           RENT     100000    28
10           0      1000    16.29     D          0           RENT      28000    22
```
Now it is time to create the model using the base function `glm()`.

```r
base_logit_loan <- glm(loan_status ~ loan_amnt + age + emp_length, family = binomial, data = loan_data_tbl)
```
That was simple and familiar. Now on to the *sparklyr* incorporation of MLlib. Now the function `ml_logistic_regression()` will be used.

```r
spark_logit_loan <- loan_data_tbl %>% ml_logistic_regression(response = "loan_status",
                                                            features = c("loan_amnt", "age", "emp_length"))
```

When trying to create this model there is an error thrown about null values:
```
Job aborted due to stage failure: Task 1 in stage 9.0 failed 1 times, most recent failure: Lost task 1.0 in stage 9.0 (TID 14, localhost): org.apache.spark.SparkException: Values to assemble cannot be null.
```
After a bit of playing around with this model and building it from the base up, it turns out that the function just doesn't seem to like the variable. I then changed the 3rd predictor to be `annual_inc`. The only difference between these two variables are the type. `emp_length` is of the class double, whereas `annual_inc` is of the class integer. I feel as this is a quite cumbersome aspect of `ml_logistic_regression()` function. Perhaps this points to some other underlying processes of Spark that I am not aware of.

Now I will create another Spark model using `annual_inc` in the place of `emp_length`. Because of this, I will create another base model using the same predictors to make sure that we can compare the models.

```r
spark_logit_ann_inc <- ml_logistic_regression(loan_data_tbl, response = "loan_status",
                                              features = c("loan_amnt","age", "annual_inc"))

# Recreate glm() using same predictors as spark logit
base_logit_ann_inc <- glm(loan_status ~ loan_amnt + age + annual_inc, family = binomial,
                          data = loan_data_tbl)
```
Since both models have been created, I would like to compare the outputs of them. Intuitively I use the function `summary()` to see the outputs of my model.

```r
summary(base_logit_ann_inc)
summary(spark_logit_ann_inc)
```


```r
> summary(base_logit_ann_inc)

Call:
glm(formula = loan_status ~ loan_amnt + age + annual_inc, family = binomial,
    data = loan_data_tbl)

Deviance Residuals:
    Min       1Q   Median       3Q      Max
-0.5702  -0.5119  -0.4855  -0.4413   3.6706

Coefficients:
              Estimate Std. Error z value Pr(>|z|)
(Intercept) -1.661e+00  9.227e-02 -17.998  < 2e-16 ***
loan_amnt    9.025e-06  3.330e-06   2.710  0.00672 **
age         -4.717e-03  3.125e-03  -1.510  0.13117
annual_inc  -5.991e-06  6.149e-07  -9.743  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 20274  on 29091  degrees of freedom
Residual deviance: 20147  on 29088  degrees of freedom
AIC: 20155

Number of Fisher Scoring iterations: 5

> summary(spark_logit_ann_inc)
Call:
loan_status ~ loan_amnt + age + annual_inc

Coefficients:
  (Intercept)     loan_amnt           age    annual_inc
-1.660598e+00  9.025112e-06 -4.716760e-03 -5.990944e-06
```

Immediately there is one key difference. The summary of the spark model only shows us the coefficients! On intitial glance, it looks as if the base function has a more robust output. However on further inspection, the spark model creates an output that holds the features (predictors), response variable, coefficients, ROC, and AUC. The key differences here are that the base model doesn't calculate ROC, and AUC. Also, in contrast, the Spark model doesn't create an output for significance levels and measures of deviance; these measures are arguably more important.
