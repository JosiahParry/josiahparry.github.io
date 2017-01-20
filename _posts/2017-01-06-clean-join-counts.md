---
title: "Cleaning & Joining Counters"
author: Josiah Parry
output: html_notebook
---


This will go through the cleaning and joining process for **LRPC** 2013 and 2014 data.

First load master **LRPC** counter data (joined with **NH DOT**), and the two function necessary for reading & cleaning raw count data: `list_dat_dirs()` and `read_counters()`.

```r
lrpc <- readRDS("data/lrpc.RDS")
```

```
## Warning in gzfile(file, "rb"): cannot open compressed file 'data/lrpc.RDS',
## probable reason 'No such file or directory'
```

```
## Error in gzfile(file, "rb"): cannot open the connection
```

```r
source("R/read_counters.R")
```

```
## Warning in file(filename, "r", encoding = encoding): cannot open file 'R/
## read_counters.R': No such file or directory
```

```
## Error in file(filename, "r", encoding = encoding): cannot open the connection
```

```r
source("R/list_dat_dirs.R")
```

```
## Warning in file(filename, "r", encoding = encoding): cannot open file 'R/
## list_dat_dirs.R': No such file or directory
```

```
## Error in file(filename, "r", encoding = encoding): cannot open the connection
```

Next read in raw counts from 2013 and 2014.

```r
counts_13 <- list_dat_dirs("/Volumes/GIS/LRPC/2013") %>% read_counters(n_skip = 2)
```

```
## Error in eval(expr, envir, enclos): could not find function "list_dat_dirs"
```

```r
counts_14 <- list_dat_dirs("/Volumes/GIS/LRPC/2014") %>% read_counters(n_skip = 3)
```

```
## Error in eval(expr, envir, enclos): could not find function "list_dat_dirs"
```
Next these data need to be associated to their counter locations / associated data from `lrpc`. The common field to be joined on is the counter field. However in the `lrpc` file the field name is `COMBNUMS` and both `counts_13` and `counts_14`, the field name is `counter`.

```r
full_counts_13 <- left_join(counts_13, lrpc, by = c("counter" = "COMBNUMS")) %>% 
  distinct(counter, date_time, total, .keep_all = T)
```

```
## Error in left_join(counts_13, lrpc, by = c(counter = "COMBNUMS")): object 'counts_13' not found
```

```r
full_counts_14 <- left_join(counts_14, lrpc, by = c("counter" = "COMBNUMS")) %>% 
  distinct(counter, date_time, total, .keep_all = T)
```

```
## Error in left_join(counts_14, lrpc, by = c(counter = "COMBNUMS")): object 'counts_14' not found
```
Now these should be saved to text files.

```r
write_csv(full_counts_13, "data/clean_counts/counters_13.csv")
```

```
## Error in is.data.frame(x): object 'full_counts_13' not found
```

```r
write_csv(full_counts_14, "data/clean_counts/counters_14.csv")
```

```
## Error in is.data.frame(x): object 'full_counts_14' not found
```
