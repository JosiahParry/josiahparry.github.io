---
title: "LRPC Traffic Counter Location Cleaning"
output: html_notebook
---

```
## Loading tidyverse: ggplot2
## Loading tidyverse: tibble
## Loading tidyverse: tidyr
## Loading tidyverse: readr
## Loading tidyverse: purrr
## Loading tidyverse: dplyr
```

```
## Conflicts with tidy packages ----------------------------------------------
```

```
## filter(): dplyr, stats
## lag():    dplyr, stats
```

The goal of this notebook is to clean, and standardize road names associated with traffic counter locations used by the Lakes Region Planning Commision (LRPC) of New Hampshire. The current data used by the **LRPC** is not in accordance with standard practice of the *NH DOT* and therefore difficult to associate with shapefiles provided by *NH GRANIT*, and other data provided by *NH DOT*. 

The first step in this is to read in all of the counter locations used by the *LRPC*, then the attribute table of the *NH GRANIT* roads shapefile. The first aim is to limit the NH Roads (attribute table of NH GRANIT roads shapefile) to the same towns as listed in the *LRPC* counter attribute table. 


```r
# Read in LRPC counter locations
all <- read_csv(file = "../Data/All_LRPCcounts.csv", progress = F) %>% 
           select(-FID)

# Read in the NH GRANIT attribute table
nh_roads <- read_csv("../../GIS/geo_spat/NH_roads/NH_roads.csv", progress = F)
```

In order to match the towns, the towns within the `all` (LRPC counters) need to be isolated, and `nh_roads` (NH GRANIT attribute table) should be filtered to only include those towns.


```r
# Isolate LRPC towns
lrpc_towns <- unique(all$Town)

# Print LRPC towns
lrpc_towns
```

```
##  [1] NA               "BARNSTEAD"      "FRANKLIN"       "GILMANTON"     
##  [5] "NORTHFIELD"     "ANDOVER"        "BELMONT"        "ALTON"         
##  [9] "TILTON"         "DANBURY"        "HILL"           "SANBORNTON"    
## [13] "LACONIA"        "GILFORD"        "ALEXANDRIA"     "BRISTOL"       
## [17] "NEW HAMPTON"    "WOLFEBORO"      "MEREDITH"       "TUFTONBORO"    
## [21] "OSSIPEE"        "MOULTONBOROUGH" "CENTER HARBOR"  "HEBRON"        
## [25] "BRIDGEWATER"    "ASHLAND"        "HOLDERNESS"     "EFFINGHAM"     
## [29] "SANDWICH"       "FREEDOM"        "TAMWORTH"
```

Note there are 30 towns (excluding the blank `""`) that are covered in the LRPC data. Now the `nh_roads` must be filtered. There should only be 30 towns in the filtered data.


```r
# Filter 
lrpc_roads <- nh_roads %>%
                filter(TOWN_NAME %in% lrpc_towns)

# View filtered town names
unique(lrpc_roads$TOWN_NAME)
```

```
##  [1] "HEBRON"         "BARNSTEAD"      "ALTON"          "LACONIA"       
##  [5] "SANDWICH"       "NORTHFIELD"     "TAMWORTH"       "WOLFEBORO"     
##  [9] "MOULTONBOROUGH" "HILL"           "BELMONT"        "TUFTONBORO"    
## [13] "ASHLAND"        "FRANKLIN"       "GILFORD"        "NEW HAMPTON"   
## [17] "GILMANTON"      "OSSIPEE"        "DANBURY"        "SANBORNTON"    
## [21] "MEREDITH"       "HOLDERNESS"     "ANDOVER"        "TILTON"        
## [25] "FREEDOM"        "EFFINGHAM"      "CENTER HARBOR"  "BRIDGEWATER"   
## [29] "BRISTOL"        "ALEXANDRIA"     NA
```

This method of matching proved to be immensely difficult. In order to most effectively match road to counter I loaded the *LRPC Counter* shapefile and the *NH Roads* shapefile into the open source geographic information system (GIS) platform **QGIS** (Quantum GIS). Initially I planned to perform an intersection as a method of geospatially joining the data, however, as with most geospatial data, the two vector files did not overlap perfectly, as not all data is going to be perfectly oriented in space. Thus required the employment of a nearest neighbor join using the *NNJoin* plugin which can be downloaded within *QGIS*. I then selectively deleted redundant fields and changed a few field names. The shapefile was exported to a **csv** and will be cleaned with **R**.


```r
# Load exported file from QGIS 
lrpc_roads <- read_csv("../../GIS/geo_spat/lrpc_roads/lrpc_roads.csv") %>% select(-X, -Y)
```

Upon inspection of the data the field `COMBNUMS` contains some observations with counter names that are associated with another counter in the format `XXXXXXXX:XXXXXXXX,XXXXXXXX`. In order to have the proper data related to each counter, the observations with the above mentioned format must be split into 3 observations: one for each counter name in the above mentioned format. 


```r
lrpc_roads <- lrpc_roads %>% 
  mutate(COMBNUMS = strsplit(COMBNUMS, "[, ]+")) %>%
  unnest(COMBNUMS)

lrpc_roads$COMBNUMS <- lrpc_roads$COMBNUMS %>% stringr::str_replace_all(":", "")
```

Preview the newly formatted `lrpc_roads$COMBNUMS`:

```r
head(lrpc_roads$COMBNUMS, n = 20)
```

```
##  [1] "82427050" "81427029" "81427028" "82025086" "82025011" "82025081"
##  [7] "82025079" "62025078" "62025051" "82025082" "82025083" "82025080"
## [13] "62163052" "82171054" "62271051" "82343044" "82343064" "61343002"
## [19] "61343001" "81343061"
```
Now time to reformat the column titles:

```r
colnames(lrpc_roads) <- colnames(lrpc_roads) %>% stringr::str_replace("_", "")
```

Now the editing of this file is complete and can be written to a *csv*.

```r
head(lrpc_roads, n = 20)
```

```
## # A tibble: 20 × 67
##           GDSNAME STATION  AREA PERIMETER COUNTERS COUNTERSI  COUNTER
##             <chr>   <chr> <int>     <int>    <int>     <int>    <chr>
## 1     CNTR:427050  427050     0         0     3377      3377 82427050
## 2     CNTR:427050  427050     0         0     3377      3377 82427050
## 3     CNTR:427050  427050     0         0     3377      3377 82427050
## 4     CNTR:025086  025086     0         0     3592      3592 82025086
## 5     CNTR:025011  025011     0         0     3593      3593 82025011
## 6     CNTR:025081  025081     0         0     3594      3594 82025081
## 7     CNTR:025079  025079     0         0     3595      3595 82025079
## 8     CNTR:025078  025078     0         0     3596      3596 62025078
## 9     CNTR:025051  025051     0         0     3597      3597 62025051
## 10    CNTR:025082  025082     0         0     3598      3598 82025082
## 11    CNTR:025083  025083     0         0     3599      3599 82025083
## 12    CNTR:025080  025080     0         0     3600      3600 82025080
## 13    CNTR:163052  163052     0         0     3645      3645 62163052
## 14    CNTR:171054  171054     0         0     3646      3646 82171054
## 15    CNTR:271051  271051     0         0     3649      3649 62271051
## 16    CNTR:343044  343044     0         0     3654      3654 82343044
## 17    CNTR:343064  343064     0         0     3655      3655 82343064
## 18 CNTR:343002:SB  343002     0         0     3656      3656 61343002
## 19 CNTR:343001:NB  343001     0         0     3657      3657 61343001
## 20    CNTR:343061  343061     0         0     3658      3658 81343061
## # ... with 60 more variables: TYPE <chr>, Group <int>, TYPE1 <chr>,
## #   Cycle <int>, CNTRNUM <dbl>, Town <chr>, Location <chr>,
## #   OBJECTID1 <dbl>, UNIQUEID <int>, SRI <chr>, MPSTART <dbl>,
## #   MPEND <dbl>, STREET <chr>, TOWNID <chr>, TOWNDOT <chr>,
## #   SECTLENGT <dbl>, FUNCTSYST <int>, FUNCTSY_1 <chr>, URBANID <int>,
## #   URBANNAME <chr>, TIER <int>, TIERDESCR <chr>, LCLEGEND <chr>,
## #   LEGISCLAS <chr>, WINTERMAI <chr>, SUMMERMAI <chr>, OWNERSHIP <chr>,
## #   OWNERSHIP <chr>, HPMSOWNER <int>, HPMSOWN_1 <chr>, PLOWLEVEL <int>,
## #   SURFTYPE <chr>, ROADWAYWI <int>, NUMLANES <int>, LANEWIDTH <int>,
## #   SHLDRTYPE <chr>, SHLDRTY_1 <chr>, SHLDRWIDT <int>, SHLDRWI_1 <int>,
## #   DIRECTION <chr>, ISTOLL <chr>, ISNHS <chr>, NHS <int>, NHSDESCR <chr>,
## #   ISTRK_ROU <chr>, COUNTYID <int>, COUNTYNAM <chr>, EXECCOUNC <int>,
## #   EXECCOU_1 <chr>, COUNTERID <chr>, AADTCURR_ <int>, AADT <int>,
## #   ROUTEHIOR <chr>, STREETALI <chr>, NODE1 <chr>, NODE2 <chr>,
## #   HPMSFACIL <int>, HPMSFAC_1 <chr>, HPMSTHRU_ <int>, COMBNUMS <chr>
```

```r
#write_csv(lrpc_roads, "../data/lrpc_counters.csv")
```




