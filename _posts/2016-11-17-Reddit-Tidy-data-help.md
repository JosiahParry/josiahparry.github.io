# Tidy your employee data
Josiah Parry  
November 17, 2016  
This notebook was used to help a fellow redditor with their data issues. 


Hey there! I think this document might be the best way to help you out so you can see how I'm thinking through this. First and foremost there are two packages that you will need to use, these being from the [tidyverse](https://blog.rstudio.org/2016/09/15/tidyverse-1-0-0/). Chances are you have heard of the *tidyverse*, and you will probably not stop hearing about it. It's essentially a set of packages created by [Hadley Wickham](http://hadley.nz/), [Garret Grolemund](https://github.com/garrettgman) (both from R-Studio), [David Robinson](https://github.com/dgrtwo), and others with a set of [tidy principles](http://vita.had.co.nz/papers/tidy-data.pdf).

First and foremost load the packages you need: 

```r
library(tidyr)
library(dplyr)
```
Here is how I created the sample data you provided:

```r
# Create tables
tbl1 <- data_frame(employee = c(1:5),
                   department = c("Dept1","Dept1", "Dept2", "Dept3", "Dept2"),
                   date = c(rep("01-01-16",5)),
                   calls_made = c(100,50,170,85,75),
                   training_time = c(0,10,20,5,30))


tbl2 <- data_frame(date = c(rep("01-01-16", 3)),
                   Dept1 = c("$100", "$50", "$75"),
                   Dept2 = c("$300", "$100", "$25"),
                   Dept3= c("0", "$1000", "$90"))
```
Let's preview it, just so you can get an idea of how the data are formated:


```r
head(tbl1)
```

```
## # A tibble: 5 × 5
##   employee department     date calls_made training_time
##      <int>      <chr>    <chr>      <dbl>         <dbl>
## 1        1      Dept1 01-01-16        100             0
## 2        2      Dept1 01-01-16         50            10
## 3        3      Dept2 01-01-16        170            20
## 4        4      Dept3 01-01-16         85             5
## 5        5      Dept2 01-01-16         75            30
```

```r
head(tbl2)
```

```
## # A tibble: 3 × 4
##       date Dept1 Dept2 Dept3
##      <chr> <chr> <chr> <chr>
## 1 01-01-16  $100  $300     0
## 2 01-01-16   $50  $100 $1000
## 3 01-01-16   $75   $25   $90
```
###Tidying

Now on to the fun part, **tidying**. Your second table has a few things going on. Your column headers are actually a factor level you want within another *variable* called `department`. In order to arrage these data to match the long & tidy format of your first table, you will need to use the function `gather()` from the `tidyr` package. 

#### gather() function

The gather function takes a number of arguments. As an aside, I always have to go back to my notes on `gather()` and `spread()` tidying functions. The first argument needed is `data`, but I personally think it is best practice to **pipe** in the data argument using the *pipe operator* (`%>%`). The pipe essentially sends the data from left to right. Next is the name of the variable that is currently the column headers, in this case `department` (this is referred in the documentation as the `key`). Following the `key` argument is the `value` argument, which are the values underneath the keys (in your case `earnings`). Lastly we need to specify which columns to gather on. For your case I specified everything **BUT** the `date` variable. 


```r
tbl2_long <- tbl2 %>% gather(department, earnings, -date)

# Preview tbl2_long
head(tbl2_long)
```

```
## # A tibble: 6 × 3
##       date department earnings
##      <chr>      <chr>    <chr>
## 1 01-01-16      Dept1     $100
## 2 01-01-16      Dept1      $50
## 3 01-01-16      Dept1      $75
## 4 01-01-16      Dept2     $300
## 5 01-01-16      Dept2     $100
## 6 01-01-16      Dept2      $25
```

#### Inconsistent Data
Now if you look at both of your tables you may notice that your second data frame doesn't contain information about your employees. So combining these data will corrupt your individual employee performance. So the best option I see is to summarize each table by **Department**. In addition to this problem, the `earnings` for the second table are stored as *strings*, and you can't sum up the alphabet, so that will have to converted into a numeric. 

Assuming that there will be multiple dates in these tables, the tables will be grouped by **Department & Date**.

I used some handy functions from `dplyr` package to create the summary tables.

```r
tbl1_depts <- tbl1 %>% 
                       group_by(department, date) %>% # Groups by department first, then date
                       summarize(number_employees = n(), # number employes is the number of times Dept# Occurs 
                                 calls_made = sum(calls_made), # The total number of calls made by each employee
                                training_time = sum(training_time)) # The sum ammount of training time for all employees

head(tbl1_depts)
```

```
## Source: local data frame [3 x 5]
## Groups: department [3]
## 
##   department     date number_employees calls_made training_time
##        <chr>    <chr>            <int>      <dbl>         <dbl>
## 1      Dept1 01-01-16                2        150            10
## 2      Dept2 01-01-16                2        245            50
## 3      Dept3 01-01-16                1         85             5
```

Cleaning the second table required changed `earnings` into a numeric. The `stringr` package is a helpful package from the **tidyverse** to clean strings. 

```r
library(stringr)

tbl2_long$earnings <- tbl2_long$earnings %>% 
                        str_replace_all("\\$", "") %>% # "\\" are escape characters makes "$" detectable
                        as.numeric() # Converts strings into numerics
```
Then rinse and repeat the summary for the second table. The only difference are the fields used.

```r
tbl2_depts <- tbl2_long %>% 
                        group_by(department, date) %>% 
                        summarize(earnings = sum(earnings))
```

### Merging
This is extremely easy with the use of the **dplyr** package. We will use an `inner_join()`. Inner joins return all columns from both data, where there are matching observations in both tables (referred to as *x and y*). 

I personally prefer a `full_join()` because it will preserve `NA`s. However the outcome is the same for these tables.


```r
tbl_full <- tbl1_depts %>% inner_join(tbl2_depts)

tbl_full
```

```
## Source: local data frame [3 x 6]
## Groups: department [?]
## 
##   department     date number_employees calls_made training_time earnings
##        <chr>    <chr>            <int>      <dbl>         <dbl>    <dbl>
## 1      Dept1 01-01-16                2        150            10      225
## 2      Dept2 01-01-16                2        245            50      425
## 3      Dept3 01-01-16                1         85             5     1090
```

####I hope that was helpful!

