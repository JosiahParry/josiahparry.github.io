---
title: "Writing CSVTs for QGIS in R"
subtitle: "Expediting your R & QGIS workflow"
tags: R
category: R
---
<meta name="twitter:card" content="summary">
<meta name="twitter:site" content="@josiahparry">
<meta name="twitter:creator" content="@josiahparry">
<meta name="twitter:image" content="http://josiahparry.com/images/favicon.png">
<meta name="twitter:text:title" content="Josiah Parry: Writing CSVTs for QGIS in R">
<meta name="twitter:text:description" content="Much of my GIS work is done in R using the tools offered by the tidyverse. However, I have always faced one troubling problem with QGIS.">
<meta property="og:image" content="http://josiahparry.com/images/favicon.png">

Much of my *GIS* work is done in *R* by aggregating and summarizing data sets using the data manipulation tools offered by the tidyverse. However, I have always faced one troubling problem with [**QGIS**](https://www.google.com/search?q=qgis&oq=qgis&aqs=chrome.0.0l2j69i59j0j69i60j0.902j0j4&sourceid=chrome&ie=UTF-8). In order for **QGIS** to understand what type of fields are provided in a text delimited file, it needs an accompanying text file known as a **csvt**. **csvt**s are unique, and I have never seen anything like them in other programs. <!--split--> The way a **csvt** works is by specifying the type of each field in the text file. For example you might have a file `county_poverty.csv`, and want to associate it to your `county.shp` shapefile in **QGIS**. In order for **QGIS** to read your fields properly, you would need to provide a supplemental file called `county_poverty.csvt`, which might look like `"Integer", "Real", "String", "Date"`.

I have alway just gone with the dirty route of opening my text editor and manually entering the field types. Recently I have been needing to many more conversions from **R** to **QGIS**, and it has been bothering me. Like any other programmer with a problem, I spent *a lot of time* to make it a lot shorter in the future.

I created two functions, [`make_csvt()`](https://github.com/JosiahParry/general_R/blob/master/personal_functions/make_csvt.R) and [`write_csvt()`](https://github.com/JosiahParry/general_R/blob/master/personal_functions/write_csvt.R) which work wonderfully together.

The first function is essentially a lookup table that takes all classes from a data frame, and writes their counterpart in **QGIS**. It looks like:

```
make_csvt <- function(data_frame) {
  lookup_table <- c("character" = "String",
                    "factor" = "String",
                    "Date" = "Date",
                    "numeric" = "Real",
                    "logical" = "String",
                    "integer" = "Integer")

  paste0('"', unname(lookup_table[unname(unlist(dplyr::bind_rows(lapply(data_frame, class))))]), '"')
}
```
This function creates the output that is to be written by the `write_csvt()` function, which is quite simple:

```
write_csvt <- function(csvt, path = getwd()) {
  writeLines(csvt, path, sep = ",")
}
```
This function requires a **csvt** string (i.e. `"String", "Date", etc.`) and a path name ending in `.csvt`.

I resorted to the `writeLines()` function as the functions `write.csv()` and `readr::write_csv()` both gave me either a blank or `X` row column no matter how many different ways I specified `row.names = FALSE`.

## Example

Lets take the iris data set and pretend we wanted to join it with a geospatial data set in **QGIS**.

```
library(tidyverse)
data("iris")

# Preview data
head(iris)
  Sepal.Length Sepal.Width Petal.Length Petal.Width Species
1          5.1         3.5          1.4         0.2  setosa
2          4.9         3.0          1.4         0.2  setosa
3          4.7         3.2          1.3         0.2  setosa
4          4.6         3.1          1.5         0.2  setosa
5          5.0         3.6          1.4         0.2  setosa
6          5.4         3.9          1.7         0.4  setosa
```

Now we want to export it as a `.csv` and `.csvt`:

```
readr::write_csv(iris, "/Users/Josiah/Desktop/iris.csv")
write_csvt(iris, "/Users/Josiah/Desktop/iris.csvt")
```

#### Baddabing, baddahboom!

You now can import this dataset into **QGIS** no problem!


If you have any tips about making this code even more efficient, let me know on [twitter](https://twitter.com/JosiahParry) or [email](mailto:josiah.parry@yahoo.com?Subject=Your%20Code%20Stinks%20I%20Can%20Make%20It%20Better!)!
