---
title: "Cleaning Raw Traffic Counter"
subtitle: "Custom Functions"
author: "Josiah Parry"
output: html_document
layout: default
---


# `list_dat_dirs()`
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
## character(0)
```
The output of this function is a vector of strings containing the path names of the directories that contain the raw output from **Traxpro**, and will be fed directly into the next function `read_counters()`. 

******

# `read_counters()`
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











