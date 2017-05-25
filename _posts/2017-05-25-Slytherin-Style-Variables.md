---
title: "Slytherin Style Variable"
subtitle: "The Case for Underscore Separated Variable Names"
tags: "R"
---

Today I will be tackling variable naming conventions in R. As background, R was the first programming language I learned (this probably explains my love for it). When I began I wasn't necessarily sure what to name things when I was creating objects or variables. I would create variables with ridiculous names such as `thisthing` or `mymann`. Eventually I started to contextually notice different variable naming patterns while learning R and other languages such as PHP and Python, among others. The most commonly used naming conventions I came across during this time were the following:


  - All lowercase & uppercase: `thisvariable` or `THISVARIABLE`
  - Camel case: `thisVariable` or `ThisVariable`
  - Period separated: `this.variable`
  - Underscore separated (or snake case): `this_variable`

Many arguments about variable naming conventions center around the concept of readability—that being the ability to read through anyone's code and understand what is being assigned to what, where, how, and why. This post will examine common variable naming conventions why (or why not) you should use them. Off the bat, I think we can all agree that single-case (upper or lower) variable names are difficult to read (`isthiseasytoread` or `ISTHISEASIER`? Yeah, `I_thought.not`). Let it be known that this post **only** examines variable naming conventions this is by no means a thorough style guide.

<!--split-->

## The Case for Period Separated `variable.names`

There was a point in my learning that I loved the idea of using period separated variable names. Period provided the pefect amount of spacing between each word in a variable name. It wasn't awkwardly close together like using `camelCase`. Why should you use period separeted variable names? Well, because Google said so. Their [style guide](https://google.github.io/styleguide/Rguide.xml) states explicitly *"don't use underscores or hyphens in identifiers". Their preffered form for variable names i `variable.name`, however they state that `variableName` is also accepted. Notice the complete ambivalence towards `camelCase`.

However, this naming convention is extremely unintuitive for those who come from an object-oriented programming background where class attributes and methods are accessed by using a period after a variable name. For example if you familiar with Python you might recognize the syntax `variable.upper()`. Object-oriented programming through my for quite the loop when I began learning Python. I became frustrated that I couldn't name things `variable.name`. I kept getting some silly error `"name isn't an attribute of variable"`. I mean, what gives?! For that reason, **I hereby denounce period separated variable names**.

## The Case for Underscore Separated `variable_names`

Another, and seemingly increasingly pervasive, naming convention is using an underscore to separate words in a variable name. This style is what is used by the father of, and other contributers to the [Tidyverse](http://tidyverse.org/). Hadley writes in his style guide writes:

  > Variable and function names should be lowercase. Use _ to separate words within a name. Generally, variable names should be nouns and function names should be verbs. Strive for concise but meaningful names (this is not easy!)

Further, Hadley makes the exceptionally logical statement that variables should be nouns, and function names should be verbs. This concept is intuitive. Variables tend to be data frames, vectors, or matrices, all of which are in a sense objects of some sort. Whereas functions always do something—just like a verb—to a variable Another name for this variable naming convention is *snake case*, however I prefer *slytherin style*.


## The Case for `camelCase`

Camel case has many uses in other fields of computer science and survives within R. To this date I have yet to find any compelling reason to neither use nor not use it. Google's ambivalence towards this style of variable name can be a testament to how Swiss-like it is.


## The Verdict

When I began my internship last summer I was required to write all of my code in accordance with Hadley's aforementioned style-guide. I have taken to this style of coding as it provides strong readability, doesn't conflict with those who are familiar with object-oriented languages, and it follows the same conventions as the tools that I most frequently use.
