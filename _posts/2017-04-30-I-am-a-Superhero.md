# I m a Superhero

You could say my roommate and I are superheroes. We're constantly saving the world from impending doom. We have a few superpowers, but our two strongest are recycling and reusing.

The other day in the face of rapidly increasing global temperatures and more frequent extreme weather events, we were on our way to the local grocery store when we had a slip-up and forgot our conservationist equivalent to the batarang, our reusable canvas bag (thanks to [The New Yorker](https://subscribe.newyorker.com/subscribe/newyorker/109777?source=google_sem&gclid=CjwKEAjwlpbIBRCx4eT8l9W26igSJAAuQ_HGyzx5PbIhUEPn3nXvK3l57AHi3K5Rao4iys_BktFl-xoCDdfw_wcB)).

<!--split-->

"Bro!" I exclaimed. Tucker was startled and concerned. "We forgot our reusable bags. Should we go back and get them?" He sat there and thought for a second. He didn't want to drive back. His car's catalytic converter wasn't working at full capacity and he was concerned about his emissions.

"Well," I said, "what would be worse? Us using plastic bags, or driving back home just to get our reusable ones?" We sat there googling various things for a while, but soon gave up and went about our shopping. After all of our purchases we used only three plastic grocery bags.

*What would've been worse, driving back home to get our reusable bags, or using those three bags?* As the empirical person I am, I used science (Google) and R to solve this question.

## Framing the Question
In order to solve this problem, I wanted to operationalize my previous use of the word *"worse"*. *Worse* was going to be measured in carbon dioxide emissions. I had a new research question.

**Research Question:** *What would've made my carbon footprint smallest? Driving home to get our reusable bags, or using plastic grocery bags?*

## What do the data say?

I started by evaluating the carbon footprint of my shopping bags. I first evaluated the carbon footprint of plastic. It turns out that the production and incinernation of 1kg of plastic produces nearly 6kg of CO<sub>2</sub> ([1](http://timeforchange.org/plastic-bags-and-plastic-bottles-CO2-emissions)), and each plastic grocery bag weights 5.5kg ([2](https://alumni.stanford.edu/get/page/magazine/article/?article_id=30162)). This means the total footprint for a bag is the CO<sub>2</sub> per kg, multiplied by total mass (in kg) of a grocery bag.


```r
footprint_kg <- 6
bag_mass <- 5.5

bag_footprint <- footprint_kg * bag_mass
paste("Footprint per bag is", bag_footprint, "kg.")
```

```
## [1] "Footprint per bag is 33 kg."
```
Our total footprint would have been 99kg since we used three bags. However, since we are superheros, we recylce. By reclycing we reduced our footprint by 2.5kg ([1](http://timeforchange.org/plastic-bags-and-plastic-bottles-CO2-emissions)). This changed our total output!


```r
footprint_kg <- footprint_kg - 2.5

bag_footprint <- footprint_kg * bag_mass
paste("Total footprint for 3 bags is", bag_footprint * 3, "kg")
```

```
## [1] "Total footprint for 3 bags is 57.75 kg"
```

Next up to figure out was how much our we emitted on our car ride to the store and back for our complete footprint. To figure this out, I started by figuring out how much CO<sub>2</sub> is emitted per gallon and using that as a basis for the rest of my vehicular emission analysis. According to the US Energy Information Administration, a standard gallon of E10 gasoline (gasoline that contains 10% ethanol) produces 17.68 pounds of CO<sub>2</sub> ([3](https://www.eia.gov/tools/faqs/faq.php?id=307&t=11)). Next steps were to convert this to kgs, and figure out how many miles were driven to get groceries. There are `0.454` kgs in 1 pound ([4](http://www.convertunits.com/from/lb/to/kg)) and according to Google maps, the grocery store was 1.7 miles away. I also assumed that my roommates car gets 20 miles to the gallon like he claims.

```r
ethanol_emiss <- 17.68 * 0.453592
gallons_one_way <- 1.7/20
emiss_one_way <- gallons_one_way * ethanol_emiss
paste(round(emiss_one_way, 3), "kg of CO2 emitted in a one way trip")
```

```
## [1] "0.682 kg of CO2 emitted in a one way trip"
```

This calculation might have been a little conservative due to the poor catalytic converter. Using my expert opinion, I decided that I could assume his vehicle emits 20% more than a standard car.

At this point, I was very close to figuring out which was *worse*, driving for the reusable bags, or using plastic grocery bags. My final steps were to find the total CO<sub>2</sub> emitted by my roommate and me including our driving emissions, and compare it to our driving emissions including our hypothetical drive back home.


```r
# Account for bad catalytic converter
emiss_one_way <- emiss_one_way * 1.2

# Find my actual footprint
actual_footprint <- bag_footprint * 3 + emiss_one_way * 2

# Find alternative footprint
alternative_footprint <- emiss_one_way * 4

actual_footprint
```

```
## [1] 59.38598
```

```r
alternative_footprint
```

```
## [1] 3.271959
```


It is to my dismay that I let the earth down on that day. Had we driven back, we would have emitted 55 fewer kilograms of CO<sub>2</sub>! I now know how important those reusable tote bags are. Reducing waste is a superpower we all can have, and I emplore you to use it!




_______

Sources:

Time For Change: [1](http://timeforchange.org/plastic-bags-and-plastic-bottles-CO2-emissions)<br>
Stanford: [2](https://alumni.stanford.edu/get/page/magazine/article/?article_id=30162)<br>
US EIA: [3](https://www.eia.gov/tools/faqs/faq.php?id=307&t=11)<br>
Convert Units: [4](http://www.convertunits.com/from/lb/to/kg)<br>
