#set page(width: auto, height: auto)
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#let data0 = (
  (
    label: "Control",
    min: 10,q1: 25,q2: 50,
    q3: 75,max: 90
  ),
  (
    label: "Condition aB",
    min: 32,q1: 54,q2: 60,
    q3: 69,max: 73,
    outliers: (18, 23, 78,)
  ),
)

#test-case({
  chart.boxwhisker(
    size: (10, 10),
    y-min: 0,
    y-max: 100,
    label-key: "label",
    data0)
})
