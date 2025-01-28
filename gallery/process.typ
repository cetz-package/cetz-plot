#import "@preview/cetz:0.3.1" as cetz: draw
#import "/src/lib.typ": chart

#set page(width: auto, height: auto, margin: .5cm)

#let steps = (
  [Improvise],
  [Adapt],
  [Overcome]
)

#let colors = (
  red, orange, green
).map(c => c.lighten(40%))

#cetz.canvas({
  chart.process.basic(
    steps,
    step-style: colors,
    equal-width: true,
    dir: ltr,
    name: "chart",
  )
})

#cetz.canvas({
  chart.process.chevron(
    steps,
    step-style: colors,
    equal-length: true,
    dir: ltr,
    name: "chart",
  )
})