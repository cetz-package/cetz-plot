#set page(width: auto, height: auto, margin: 1cm)
#import "/tests/helper.typ": *

#let data = (
  ([One], 1, 0.5),
  ([Two], 3, 0.75),
  ([Three], 2, 1),
)

#test-case(cetz-plot.chart.bar.simple(
  size: (10,9),
  label-key: 0,
  y-key: 1,
  y-error-key: 2,
  label: [Noot noot],
  data,
))