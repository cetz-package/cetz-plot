#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#let line-data = ((-1,-1), (1,1),)

#let data = (..(for x in range(-360, 360 + 1) {
  ((x, calc.sin(x * 1deg)),)
}))

/* Scientific Style */
#test-case({
  plot.plot(
    size: (5, 2),
    axis-style: "scientific-polar",
    x-tick-step: 180,
    y-tick-step: 1,
    x-grid: "major",
    y-grid: "major",
    {
      plot.add(data)
    })
})