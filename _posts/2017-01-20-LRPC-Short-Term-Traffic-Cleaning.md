# LRPC Short Term Traffic Cleaning

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

Now the editing of this file is complete and can be written to a *csv*. In addition to a *csv* I created an `.RDS` file for ease of access for future analyses.

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
# Cleaning Raw Short Term Count Data

This section will go through the functions I used to clean raw short term count data collected for the *LRPC*. These data were manually exported as ASCII comma separated text files and organized into directories prior to the cleaning process.


## `list_dat_dirs()`
During my first run through of cleaning the raw counter data I had to write down the file path of each raw count folder (or directory). In order to make this easier in the future I created the function `list_dat_dirs()`, or **list data directories**. The goal of this is to automate the collection of file path names. 

The function is written as follows:


```r
list_dat_dirs <- function(dir, extension = "RAW", case_sensitive = FALSE) {
  case_sensitive <- ifelse(case_sensitive == TRUE, FALSE, TRUE)
  list.dirs(dir)[str_detect(list.dirs(dir),
                                        fixed(extension, ignore_case = case_sensitive))]
}
```
### Nuances
This function will list all directories within a root directory with a specified ending extension. There are a few nuances (bugs, rather) of this function. The most important is that the target directories (those with the raw counts) should contain **only** raw count files; other nuances will be elaborated on in the following sections. 

### Function Arguments
**`dir`**: *Short for directory*
This is the path name of root directory that contains sub-directories of counts. The directory path name should be in quotations. 

  - i.e. `"/Volumes/GIS/LRPC/2014"`
  
**`extension`**: *The name of the sub-directories of counts*
The default extension name is `"RAW"` due to the formatting of data on my hard drive. This can be changed to anything, and like the `dir` argument it should be in quotations; i.e. `"RAW"`. This allows the function to search for all directories with the name **RAW**

**`case_sensitve`**
A logical argument that determines if the function should look for directories with, or without respect to case sensitivity; the default if `FALSE`.

### Example
This example will demonstrate the output / uses of the function. This example will draw directly from the raw counter cleaning I have done.

```r
list_dat_dirs("/Volumes/GIS/LRPC/2014")
```

```
##  [1] "/Volumes/GIS/LRPC/2014/Week 1 - May 12/RAW"       
##  [2] "/Volumes/GIS/LRPC/2014/Week 10 - August 11/RAW"   
##  [3] "/Volumes/GIS/LRPC/2014/Week 11 - August 18/RAW"   
##  [4] "/Volumes/GIS/LRPC/2014/Week 12 - September 8/RAW" 
##  [5] "/Volumes/GIS/LRPC/2014/Week 13 - September 15/RAW"
##  [6] "/Volumes/GIS/LRPC/2014/Week 14 - September 22/RAW"
##  [7] "/Volumes/GIS/LRPC/2014/Week 2 - May 19/RAW"       
##  [8] "/Volumes/GIS/LRPC/2014/Week 3 - June 2/RAW"       
##  [9] "/Volumes/GIS/LRPC/2014/Week 4 - June 24/RAW"      
## [10] "/Volumes/GIS/LRPC/2014/Week 5 - July 7/RAW"       
## [11] "/Volumes/GIS/LRPC/2014/Week 6 - July 14/RAW"      
## [12] "/Volumes/GIS/LRPC/2014/Week 7 - July 21/RAW"      
## [13] "/Volumes/GIS/LRPC/2014/Week 8 - July 28/RAW"      
## [14] "/Volumes/GIS/LRPC/2014/Week 9 - August 4/RAW"
```
The output of this function is a vector of strings containing the path names of the directories that contain the raw output from **Traxpro**, and will be fed directly into the next function `read_counters()`. 

******

## `read_counters()`
This function will read in raw counts and aggregate them together, while performing some mild cleaning and alterations. This function requires that all files that it reads be comma separated. This would be either in the form of **.csv** or any other text file delimted by commas. In the case of the **LRPC** data that is exported from **Traxpro** in **ASCII** format is a **.txt** extension * **comma separated** * file.

When reading in raw counts directionality is lost, only totals are given. If this becomes a problem, contact me, or submit an issue request so I can fix it. 

The function is written as follows:

```r
read_counters <- function(dat_dirs, n_skip = 0) {
  all_files <- list()
  for (i in 1:length(dat_dirs)) {
    for (j in 1:length(list.files(dat_dirs[i]))) {
      all_files[length(list.files(dat_dirs[1:i])) - (length(list.files(dat_dirs[i])) - j)] <- 
        list(read_csv(file.path(dat_dirs[i],list.files(dat_dirs[i])[j]), 
                      skip = n_skip, col_names = TRUE,
                      col_types = cols(
                        Date = col_date("%m / %d / %Y")
                      )) %>% 
               mutate(counter = list.files(dat_dirs[i])[j] %>%
                        str_replace_all(".txt", "")) %>% 
               select(Date, Time, counter, everything()))
    }
  }
  counter_clean <- function(df, total = "total") {
    df <- data.frame(df)
    if (dim(df)[2] > 4) {
      df[, total] <-  apply(df[, -c(1:3)], 1, sum)
    } else {
      df[, total] <- df[, 4]
    }
    df$date_time <- ymd_hms(paste(df$Date, df$Time))
    df <- dplyr::select(df, counter, Date, Time, date_time, total)
    `colnames<-`(df, tolower(colnames(df)))
  }
  do.call("rbind", lapply(all_files, counter_clean))
}
```

### Function Arguments
**dat_dirs**: *Short for data directories*
This argument asks for a path name (string) to the raw counter data. For example: `"..LRPC/2014/Week 2 - May 19/RAW"`.

**n_skip**:
The number of lines to skip before reading in the **csv**. The default is `n_skip = 0`, however it will most likely need to be adjusted on the output of the data. For example the raw data from 2013 has the following format:

```
## # A tibble: 6 × 1
##                                   x
##                               <chr>
## 1               Site Code: 62295051
## 2                                  
## 3 Date,Time,Direction 1,Direction 2
## 4     5/28/2013,10:00:00 AM,504,378
## 5     5/28/2013,11:00:00 AM,454,350
## 6     5/28/2013,12:00:00 PM,478,390
```
**NOTE**: If more than 1 file is being read at a time, it is imperative that each file has the same number of lines to skip. 

*****

# Cleaning workflow

1. Convert raw data to comma separated text files (**csvs**)
2. Organize raw csvs into directories containing only raw counts
3. Get raw count directory paths
3a. Feed raw count directory paths to `read_counters()`

### Case study
I will review how I cleaned 2013 data using the above functions.

I manually converted raw counts from **TraxPro** to `.txt` comma separate files and organized them into sub-directories. The file structure looks like `ROOT > YEAR > WEEK > RAW`: where there are multiple years of data in the root directory, in my case, `2013 and 2014`. Each year has a number of weeks that data was collected, and within each week folder there is another folder containing the raw count data in a `.txt` file. 

The root directory in this case is `"/Volumes/GIS/LRPC/2014"`, and the extension that contains the raw data is `"RAW"`. The first step is to obtain all of the path names containing raw data. I will assign these path names to a vector called `dat_dirs` (data directories). Note that this is the name of the main argument in the `read_counters()` function which requires a file path name.

```r
dat_dirs <- list_dat_dirs("/Volumes/GIS/LRPC/2014")

# Look at path names
dat_dirs
```

```
##  [1] "/Volumes/GIS/LRPC/2014/Week 1 - May 12/RAW"       
##  [2] "/Volumes/GIS/LRPC/2014/Week 10 - August 11/RAW"   
##  [3] "/Volumes/GIS/LRPC/2014/Week 11 - August 18/RAW"   
##  [4] "/Volumes/GIS/LRPC/2014/Week 12 - September 8/RAW" 
##  [5] "/Volumes/GIS/LRPC/2014/Week 13 - September 15/RAW"
##  [6] "/Volumes/GIS/LRPC/2014/Week 14 - September 22/RAW"
##  [7] "/Volumes/GIS/LRPC/2014/Week 2 - May 19/RAW"       
##  [8] "/Volumes/GIS/LRPC/2014/Week 3 - June 2/RAW"       
##  [9] "/Volumes/GIS/LRPC/2014/Week 4 - June 24/RAW"      
## [10] "/Volumes/GIS/LRPC/2014/Week 5 - July 7/RAW"       
## [11] "/Volumes/GIS/LRPC/2014/Week 6 - July 14/RAW"      
## [12] "/Volumes/GIS/LRPC/2014/Week 7 - July 21/RAW"      
## [13] "/Volumes/GIS/LRPC/2014/Week 8 - July 28/RAW"      
## [14] "/Volumes/GIS/LRPC/2014/Week 9 - August 4/RAW"
```
Next these path names need to be passed to `read_counters()` to be read and cleaned. But before they are read it is *imperative* that I know how many lines to skip before reading the file (this is best done through a manual inspection of the data). 

Take a look at the data, how many lines should be skipped? The answer is three as seen (somewhat difficultly) below.

```r
tidy(read_lines("/Volumes/GIS/LRPC/2014/Week 1 - May 12/RAW/61141010.txt", n_max = 8))
```

```
## # A tibble: 8 × 1
##                           x
##                       <chr>
## 1   Start Time: 12:00:00 PM
## 2       Site Code: 61141010
## 3                          
## 4     Date,Time,Direction 1
## 5 5/12/2014,12:00:00 PM,131
## 6  5/12/2014,1:00:00 PM,158
## 7  5/12/2014,2:00:00 PM,130
## 8  5/12/2014,3:00:00 PM,170
```
Now that the path names are stored in `dat_dirs` and we know how many lines to skip we can read in the counts; but make sure to store them to a variable!

```r
counts_14 <- read_counters(dat_dirs, n_skip = 3)
```

Lets preview this data!

```r
head(counts_14, n = 10)
```

```
##     counter       date        time           date_time total
## 1  61141010 2014-05-12 12:00:00 PM 2014-05-12 12:00:00   131
## 2  61141010 2014-05-12  1:00:00 PM 2014-05-12 13:00:00   158
## 3  61141010 2014-05-12  2:00:00 PM 2014-05-12 14:00:00   130
## 4  61141010 2014-05-12  3:00:00 PM 2014-05-12 15:00:00   170
## 5  61141010 2014-05-12  4:00:00 PM 2014-05-12 16:00:00   213
## 6  61141010 2014-05-12  5:00:00 PM 2014-05-12 17:00:00   155
## 7  61141010 2014-05-12  6:00:00 PM 2014-05-12 18:00:00    95
## 8  61141010 2014-05-12  7:00:00 PM 2014-05-12 19:00:00    86
## 9  61141010 2014-05-12  8:00:00 PM 2014-05-12 20:00:00    58
## 10 61141010 2014-05-12  9:00:00 PM 2014-05-12 21:00:00    32
```
Now we have a data frame containing hourly counts for each counter.

However there are alternative ways of doing this. You can either call the `list_dat_dirs()` function in the place of the `dat_dirs` argument of `read_counters()`, **OR** you can pipe the `list_dat_dirs()` into the `read_counters()`function. 

Below are both efficient ways of reading in raw counts:

```r
counts <- read_counters(list_dat_dirs("/Volumes/GIS/LRPC/2014"), n_skip = 3)

counts <- list_dat_dirs("/Volumes/GIS/LRPC/2014") %>% read_counters(n_skip = 3)
```


# Combining Short Term Counts & Locational LRPC Data


This will go through the cleaning and joining process for **LRPC** 2013 and 2014 data.

First load master **LRPC** counter data (joined with **NH DOT**), and the two function necessary for reading & cleaning raw count data: `list_dat_dirs()` and `read_counters()`.

```r
lrpc <- readRDS("../data/lrpc.RDS")
source("../R/read_counters.R")
source("../R/list_dat_dirs.R")
```

Next read in raw counts from 2013 and 2014.

```r
counts_13 <- list_dat_dirs("/Volumes/GIS/LRPC/2013") %>% read_counters(n_skip = 2)
counts_14 <- list_dat_dirs("/Volumes/GIS/LRPC/2014") %>% read_counters(n_skip = 3)
```
Next these data need to be associated to their counter locations / associated data from `lrpc`. The common field to be joined on is the counter field. However in the `lrpc` file the field name is `COMBNUMS` and both `counts_13` and `counts_14`, the field name is `counter`.

```r
full_counts_13 <- left_join(counts_13, lrpc, by = c("counter" = "COMBNUMS")) %>% 
  distinct(counter, date_time, total, .keep_all = T)

full_counts_14 <- left_join(counts_14, lrpc, by = c("counter" = "COMBNUMS")) %>% 
  distinct(counter, date_time, total, .keep_all = T)
```
Now these should be saved to text files.

```r
#write_csv(full_counts_13, "data/clean_counts/counters_13.csv")
#write_csv(full_counts_14, "data/clean_counts/counters_14.csv")
```




