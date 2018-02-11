# The average plastic grocery bag weighs 5.5kg (https://alumni.stanford.edu/get/page/magazine/article/?article_id=30162)
# Carbon footprint of 1kg of plastic is ~6kg CO2 (http://timeforchange.org/plastic-bags-and-plastic-bottles-CO2-emissions)

footprint <- 6 #kg CO2per kg of plastic
grocery <- 5.5 #kg of plastic

footprint_per_bag <- grocery * footprint #kg of CO2

# Say we estimate we use 3 grocery bags and could have fit all in our one reusable canvas bag
total_bag_footprint <- footprint_per_bag * 3

## Look at car
# approximately 17.68lbs of CO2 are emitted from a gallon Gasoline with 10% ethanol (standard US gas)
# Find the emissions per gallon of gas in kg of CO2
ethanol_emiss <- 17.68 * 0.453592
#1lb = 0.453592kg (http://www.convertunits.com/from/lb/to/kg)

# Trip to the supermarket is approximately 1.7miles, thanks to google maps
# Need to figure out how much gasoline was used (miles traveled divided by cars mpg)
gallons_used <- 1.7/20
gas_emissions <- ethanol_emiss * gallons_used

# Since the gas_emissions is only for one direction, once we arrived and realized we forgot our bags we would have to drive the distance 2 more times than we should!
gas_emissions <- (gallons_used * 2) * ethanol_emiss


# However, assuming that we are good recycling college students, we reduce our carbon footprint by 2.5kg CO2 per kg of plastic, we can recalculate but, reducing our footprint
footprint <- 3.5
footprint_per_bag <- grocery * footprint
total_bag_footprint <- footprint_per_bag * 3
