# How Do We Draw a Line?

In this experiment I explore the Google Quick Draw dataset. In its [Github website](https://github.com/googlecreativelab/quickdraw-dataset) you can see a detailed description of the data. Briefly, it contains  around 50 million of drawings of people around the world in `.ndjson` format. In this experiment, I used the simplified version of drawings where:

+ strokes are simplified and resampled with a 1 pixel spacing
+ drawings are also aligned to top-left corner and scaled to have a maximum value of 255

Th goal of the experiment is to understand how do we draw lines: horizontally? toward right o left? vertically? toward up or down? We will also check if there are differences among countries.

## Inspiration

+ [How do you draw a circle?](https://qz.com/994486/the-way-you-draw-circles-says-a-lot-about-you/) by [Quartz](https://qz.com/), an amazing analysis which shows how cultural circumstances strongly determine the way in which we draw circles.
+ [City Street Orientations around the World](https://geoffboeing.com/2018/07/city-street-orientations-world/) by [Geoff Boeing](https://geoffboeing.com/), an awesome analysis and data visualization which gave me the idea of doing polar graphs to show my results.

## Getting Started

### Prerequisites

You will need to install the following packages (if you don't have them already):

```
install.packages("data.table")
install.packages("plyr")
install.packages("dplyr")
install.packages("rjson")
install.packages("ggplot2")
install.packages("purrr")
install.packages("broom")
install.packages("ISOcodes")
install.packages("xkcd")
```

## Instructions

1. After cloning the repo, download `line.ndjson` dataset from [here](https://storage.googleapis.com/quickdraw_dataset/full/simplified/line.ndjson) and place it on the a folder called `data` inside your project folder in R.
1. To use `xkdc`fonts follow [this instructions](https://cran.r-project.org/web/packages/xkcd/vignettes/xkcd-intro.pdf)

## More info

A complete explanation of the experiment can be found [at fronkonstin](https://fronkonstin.com)

## Authors

* **Antonio Sánchez Chinchón** - [@aschinchon](https://twitter.com/aschinchon)

