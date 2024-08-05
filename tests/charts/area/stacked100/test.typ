#set page(width: auto, height: auto, margin: 1cm)
#import "/tests/helper.typ": *

#let data = (
  (0,    18.0, 20.1, 23.0, 17.0),
  (2.5,  16.3, 17.6, 19.4, 15.3),
  (5,    14.0, 15.3, 13.9, 18.7),
  (7.5,  35.5, 26.5, 29.4, 25.8),
  (10,   25.0, 20.6, 22.4, 22.0),
  (12.5, 19.9, 18.2, 19.2, 16.4),
)

#let x-list = (0,  3.3,  6.6, 9.9)

#test-case(cetz-plot.chart.area.stacked(
  size: (10,9),
  x-key: 0,
  y-keys: (1,2,3,4),
  x-list: x-list,
  labels: ([Low], [Medium], [High], [Very high]),
  data,
))
