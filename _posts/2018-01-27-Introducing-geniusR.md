---
title: Introducing geniusR
category: R
subtitle: Basics for acquiring song lyrics as text data
excerpt: "geniusR enables quick and easy download of song lyrics. The intent behind the package is to be able to perform text based analyses on songs in a tidy[text] format."

---

<p> </p>

# Introducing geniusR

`geniusR` enables quick and easy download of song lyrics. The intent behind the package is to be able to perform text based analyses on songs in a tidy[text] format.

This package was inspired by the release of Kendrick Lamar's most recent album, **DAMN.**. As most programmers do, I spent way too long to simplify a task, that being accessing song lyrics. Genius (formerly Rap Genius) is the most widly accessible platform for lyrics.

<!--split-->

The functions in this package enable easy access of individual song lyrics, album tracklists, and lyrics to whole albums.

## Individual songs `genius_lyrics()`

Getting lyrics to a single song is pretty easy. Let's get in our **ELEMENT.** and checkout **DNA.**. But first, note that the `genius_lyrics()` function takes two arguments, `artist` and `song`. Be sure to spell the name of the artist and the song correctly, but don't worry about capitalization.

First, let's set up our libraries / working environment.

<pre><code class="prettyprint">
devtools::install_github("josiahparry/geniusR")
library(geniusR)
library(tidyverse)
library(tidytext)
</code></pre>

`genius_lyrics()` returns only the barebones. Utilizing `dplyr` we can also create a new variable with the line number to help in future [tidytext](https://github.com/juliasilge/tidytext) analysis. This will be covered in a later vignette / post.


<pre><code class="prettyprint ">DNA &lt;- genius_lyrics(artist = &quot;Kendrick Lamar&quot;, song = &quot;DNA.&quot;)
DNA %&gt;%
  mutate(line = row_number())</code></pre>



<pre><code>## # A tibble: 99 x 2
##    text                                                              line
##    &lt;chr&gt;                                                            &lt;int&gt;
##  1 I got, I got, I got, I got—                                          1
##  2 Loyalty, got royalty inside my DNA                                   2
##  3 Cocaine quarter piece, got war and peace inside my DNA               3
##  4 I got power, poison, pain and joy inside my DNA                      4
##  5 I got hustle though, ambition flow inside my DNA                     5
##  6 I was born like this, since one like this, immaculate conception     6
##  7 I transform like this, perform like this, was Yeshua new weapon      7
##  8 I don't contemplate, I meditate, then off your fucking head          8
##  9 This that put-the-kids-to-bed                                        9
## 10 This that I got, I got, I got, I got—                               10
## # ... with 89 more rows
</code></pre>

## Album Level Information

### Tracklists

There are two key functions to be utilized at the album level: `genius_tracklist()` and `genius_album()`.

I often only know an album name and none of the track titles. Often I only know the position in the tracklist. For this reason, I created a tool to provide an album tracklist. This function, `genius_tracklist()` takes the arguments `artist` and `album`. Simple enough, right?

Let's get the tracklist for the original release of **DAMN.**. However, real Kendrick fans know that the album was intended to be listened to in chronological *and* reverse order—as is on the collector's release.



<pre><code class="prettyprint ">damn_tracks &lt;- genius_tracklist(artist = &quot;Kendrick Lamar&quot;, album = &quot;DAMN.&quot;)

# Collector's reverse order
damn_tracks %&gt;%
  arrange(-track_n)</code></pre>



<pre><code>## # A tibble: 14 x 2
##    title                  track_n
##    &lt;chr&gt;                    &lt;int&gt;
##  1 DUCKWORTH.               14
##  2 GOD.                     13
##  3 FEAR.                    12
##  4 XXX. (Ft. U2)            11
##  5 LOVE. (Ft. Zacari)       10
##  6 LUST.                     9
##  7 HUMBLE.                   8
##  8 PRIDE.                    7
##  9 LOYALTY. (Ft. Rihanna)    6
## 10 FEEL.                     5
## 11 ELEMENT.                  4
## 12 YAH.                      3
## 13 DNA.                      2
## 14 BLOOD.                    1
</code></pre>

### Album Lyrics

If lyrics for a full album are what you desire, look no further than `genius_album()`. With a little help from [`purrr`](https://github.com/tidyverse/purrr) you can avoid the annoying iterations! `genius_album()` is designed for simple use. Provide it with only two argument—`artist` and `album`—and you'll have lyrics in no time!

`genius_album()` returns a tibble with a column of nested data frames where each song's lyrics are contained. Nesting the lyrics was done to have a less cluttered data frame. You can unnest the lyrics by setting `nested = FALSE`. Alternatively, you can pipe it into an `unnest()` call.



<pre><code class="prettyprint ">DAMN &lt;- genius_album(artist = &quot;Kendrick Lamar&quot;, album = &quot;DAMN.&quot;, nested = FALSE)

# Alternative method
#genius_album(artist = &quot;Kendrick Lamar&quot;, album = &quot;DAMN.&quot;) %&gt;%
#  unnest(lyrics)

head(DAMN)</code></pre>



<pre><code>## # A tibble: 6 x 4
##   title  track_n text                                                 line
##   &lt;chr&gt;    &lt;int&gt; &lt;chr&gt;                                               &lt;int&gt;
## 1 BLOOD.       1 Is it wickedness?                                       1
## 2 BLOOD.       1 Is it weakness?                                         2
## 3 BLOOD.       1 You decide                                              3
## 4 BLOOD.       1 Are we gonna live or die?                               4
## 5 BLOOD.       1 &quot;So I was takin' a walk the other day, and I seen …     5
## 6 BLOOD.       1 {Gunshot}                                               6
</code></pre>

Bam. Easy peasy. Now you have a sweet data frame ready for a tidy text analysis!
