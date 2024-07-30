#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#let line-data = ((-1,-1), (1,1),)

#let data = (..(for x in range(-360, 360 + 1) {
  ((x, calc.sin(x)),)
}))

/* Scientific Style */
#test-case({
  plot.plot(
    size: (5,5),
    axis-style: "scientific-polar",

    x-tick-step: calc.pi / 8,
    x-minor-tick-step: calc.pi / 16,
    x-grid: "both",

    y-min: 0, y-max: 1,
    y-tick-step: 0.5,
    y-minor-tick-step: 0.125,
    y-grid: "both",
    {
      plot.add((t)=>0.5*(calc.sin(t)+1), domain: (0, 2*calc.pi), line: "raw")
    })
})