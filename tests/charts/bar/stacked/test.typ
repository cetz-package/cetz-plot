#set page(width: auto, height: auto, margin: 1cm)
#import "/tests/helper.typ": *

#let data = (
  ([15-24], 18.0, 20.1, 23.0, 17.0),
  ([25-29], 16.3, 17.6, 19.4, 15.3),
  ([30-34], 14.0, 15.3, 13.9, 18.7),
  ([35-44], 35.5, 26.5, 29.4, 25.8),
  ([45-54], 25.0, 20.6, 22.4, 22.0),
  ([55+],   19.9, 18.2, 19.2, 16.4),
)

#test-case(cetz-plot.chart.bar.stacked(
  size: (10,9),
  label-key: 0,
  y-keys: (1,2,3,4),
  labels: ([Low], [Medium], [High], [Very high]),
  data
))