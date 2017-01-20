    ## Loading tidyverse: ggplot2
    ## Loading tidyverse: tibble
    ## Loading tidyverse: tidyr
    ## Loading tidyverse: readr
    ## Loading tidyverse: purrr
    ## Loading tidyverse: dplyr

    ## Conflicts with tidy packages ----------------------------------------------

    ## filter(): dplyr, stats
    ## lag():    dplyr, stats

Question:
=========

Of the counters used to calculate seasonal averages, how many of them are in the lakes region?
----------------------------------------------------------------------------------------------

``` r
lrpc <- read_csv("../data/lrpc_counters.csv")
fctr_grp_15 <- read_csv("../data/15_factor_grp.csv",
                        col_types = 
                          list(col_double(), col_character(), col_character(), col_character()))

head(lrpc)
```

    ## # A tibble: 6 × 67
    ##       GDSNAME STATION  AREA PERIMETER COUNTERS COUNTERSI  COUNTER  TYPE
    ##         <chr>   <chr> <int>     <int>    <int>     <int>    <chr> <chr>
    ## 1 CNTR:427050  427050     0         0     3377      3377 82427050    82
    ## 2 CNTR:427050  427050     0         0     3377      3377 82427050    82
    ## 3 CNTR:427050  427050     0         0     3377      3377 82427050    82
    ## 4 CNTR:025086  025086     0         0     3592      3592 82025086    82
    ## 5 CNTR:025011  025011     0         0     3593      3593 82025011    82
    ## 6 CNTR:025081  025081     0         0     3594      3594 82025081    82
    ## # ... with 59 more variables: Group <int>, TYPE1 <chr>, Cycle <int>,
    ## #   CNTRNUM <int>, Town <chr>, Location <chr>, OBJECTID1 <int>,
    ## #   UNIQUEID <int>, SRI <chr>, MPSTART <dbl>, MPEND <dbl>, STREET <chr>,
    ## #   TOWNID <chr>, TOWNDOT <chr>, SECTLENGT <dbl>, FUNCTSYST <int>,
    ## #   FUNCTSY_1 <chr>, URBANID <int>, URBANNAME <chr>, TIER <int>,
    ## #   TIERDESCR <chr>, LCLEGEND <chr>, LEGISCLAS <chr>, WINTERMAI <chr>,
    ## #   SUMMERMAI <chr>, OWNERSHIP <chr>, OWNERSHIP <chr>, HPMSOWNER <int>,
    ## #   HPMSOWN_1 <chr>, PLOWLEVEL <int>, SURFTYPE <chr>, ROADWAYWI <int>,
    ## #   NUMLANES <int>, LANEWIDTH <int>, SHLDRTYPE <chr>, SHLDRTY_1 <chr>,
    ## #   SHLDRWIDT <int>, SHLDRWI_1 <int>, DIRECTION <chr>, ISTOLL <chr>,
    ## #   ISNHS <chr>, NHS <int>, NHSDESCR <chr>, ISTRK_ROU <chr>,
    ## #   COUNTYID <int>, COUNTYNAM <chr>, EXECCOUNC <int>, EXECCOU_1 <chr>,
    ## #   COUNTERID <chr>, AADTCURR_ <int>, AADT <int>, ROUTEHIOR <chr>,
    ## #   STREETALI <chr>, NODE1 <chr>, NODE2 <chr>, HPMSFACIL <int>,
    ## #   HPMSFAC_1 <chr>, HPMSTHRU_ <int>, COMBNUMS <chr>

``` r
head(fctr_grp_15)
```

    ## # A tibble: 6 × 4
    ##   GROUP COUNTER      TOWN
    ##   <dbl>   <chr>     <chr>
    ## 1     1 2067002   CAMPTON
    ## 2     1 2197090   HAMPTON
    ## 3     1 2265092 LITTLETON
    ## 4     1 2409003  SEABROOK
    ## 5     1 2439005    SUTTON
    ## 6     1 2451001    TILTON
    ## # ... with 1 more variables: LOCATION <chr>

The `lrpc` data frame contains all of the counters used by the **LRPC**, and the `fctr_grp_15` identifies all of the counters used by the **NH DOT** in the calculation of *seasonal adjustment factors*. The question to be assessed is: how many of these counters used by the **NH DOT** are within the **LRPC's** area? The hypothesis is that the Lakes Region is a very unique place with respect to recreation and tourism and therefore may be an anomoly in traffic analysis, and thus it's average traffic count may be dampened by other counters within it's same adjustment factor grouping.

To identify which factors are the **LRPC's** in the seasonal adjustment factor evaluation I will identify the counters from `fctr_grp_15` which are in the 30 towns of the Lakes Region.

The following code isolates all of the towns in the Lakes Region.

``` r
lrpc_towns <- sort(unique(na.omit(lrpc$Town)))
length(lrpc_towns)
```

    ## [1] 30

Next step is to isolate the counters that are used in the seasonal adjustment factor creation that are *within* the Lakes Region.

``` r
saf_counters_15 <- fctr_grp_15 %>%
  filter(TOWN %in% lrpc_towns)

saf_counters_15 %>% arrange(COUNTER)
```

    ## # A tibble: 9 × 4
    ##   GROUP  COUNTER      TOWN
    ##   <dbl>    <chr>     <chr>
    ## 1     5  2011001     ALTON
    ## 2     5  2169053   GILFORD
    ## 3     4 22039022   BELMONT
    ## 4     5  2295022  MEREDITH
    ## 5     5  2357021   OSSIPEE
    ## 6     5  2443001  TAMWORTH
    ## 7     1  2451001    TILTON
    ## 8     5 62493054 WOLFEBORO
    ## 9     2 82015056   ANDOVER
    ## # ... with 1 more variables: LOCATION <chr>

Above we can see the 9 counters that are used in the calculation of **AADT** that are within the Lakes Region. But it does look like the counters had their leading `0's` left out, this might cause a future problem. This is an easy fix.

``` r
saf_counters_15$COUNTER <-  str_pad(saf_counters_15$COUNTER, 8, side = "left", pad = "0")
saf_counters_15
```

    ## # A tibble: 9 × 4
    ##   GROUP  COUNTER      TOWN
    ##   <dbl>    <chr>     <chr>
    ## 1     1 02451001    TILTON
    ## 2     2 82015056   ANDOVER
    ## 3     4 22039022   BELMONT
    ## 4     5 02011001     ALTON
    ## 5     5 02169053   GILFORD
    ## 6     5 02295022  MEREDITH
    ## 7     5 02357021   OSSIPEE
    ## 8     5 02443001  TAMWORTH
    ## 9     5 62493054 WOLFEBORO
    ## # ... with 1 more variables: LOCATION <chr>

Now I must repeat this for the years **2013 & 2014**.

``` r
fctr_grp_14 <- read_csv("../data/14_factor_grp.csv",
                        col_types = 
                          list(col_double(), col_character(), col_character(), col_character()))

fctr_grp_13 <- read_csv("../data/13_factor_grp.csv",
                        col_types = 
                          list(col_double(), col_character(), col_character(), col_character()))

saf_counters_14 <- fctr_grp_14 %>%
  filter(TOWN %in% lrpc_towns)

saf_counters_13 <- fctr_grp_13 %>%
  filter(TOWN %in% lrpc_towns)
```

Verify that they are all the same:

``` r
saf_counters_13 %>% arrange(TOWN)
```

    ## # A tibble: 9 × 4
    ##     GRP  counter      TOWN
    ##   <dbl>    <chr>     <chr>
    ## 1     5 02011001     ALTON
    ## 2     2 82015056   ANDOVER
    ## 3     5 22039022   BELMONT
    ## 4     5 02169053   GILFORD
    ## 5     5 02295022  MEREDITH
    ## 6     5 02357021   OSSIPEE
    ## 7     5 02443001  TAMWORTH
    ## 8     1 02451001    TILTON
    ## 9     5 62493054 WOLFEBORO
    ## # ... with 1 more variables: LOCATION <chr>

``` r
saf_counters_14 %>% arrange(TOWN)
```

    ## # A tibble: 9 × 4
    ##     GRP  counter      TOWN
    ##   <dbl>    <chr>     <chr>
    ## 1     5 02011001     ALTON
    ## 2     2 82015056   ANDOVER
    ## 3     5 22039022   BELMONT
    ## 4     5 02169053   GILFORD
    ## 5     5 02295022  MEREDITH
    ## 6     5 02357021   OSSIPEE
    ## 7     5 02443001  TAMWORTH
    ## 8     1 02451001    TILTON
    ## 9     5 62493054 WOLFEBORO
    ## # ... with 1 more variables: LOCATION <chr>

``` r
saf_counters_15 %>% arrange(TOWN)
```

    ## # A tibble: 9 × 4
    ##   GROUP  COUNTER      TOWN
    ##   <dbl>    <chr>     <chr>
    ## 1     5 02011001     ALTON
    ## 2     2 82015056   ANDOVER
    ## 3     4 22039022   BELMONT
    ## 4     5 02169053   GILFORD
    ## 5     5 02295022  MEREDITH
    ## 6     5 02357021   OSSIPEE
    ## 7     5 02443001  TAMWORTH
    ## 8     1 02451001    TILTON
    ## 9     5 62493054 WOLFEBORO
    ## # ... with 1 more variables: LOCATION <chr>

The continuous counters for the years *2013 & 2014* are identical. Only in *2015* did the counter in *Belmont* change from group 5 to group 4. Now I'm going to write these table to an R file to be accessed in calculating each years adjustments.

``` r
#saveRDS(saf_counters_13, "../data/factors_13_14.rds")
#saveRDS(saf_counters_15, "../data/factors_15.rds")
```
