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

  draw.set-style(
    axes: (tick: (label: (position: "south"))),
    legend: (stroke: none, achor: "west")
  )

  plot.plot(
    size: (16,9),
    axis-style: "scientific-polar",

    x-tick-step: calc.pi / 4,
    x-minor-tick-step: calc.pi / 16,
    x-grid: "both",
    x-min: 0, x-max: 2 * calc.pi,

    y-min: -1, y-max: 1,
    y-tick-step: 0.5,
    y-minor-tick-step: 0.125,
    y-grid: "both",

    legend: "east",
    {
      plot.add(
        calc.sin,
        domain: (0, 2* calc.pi), 
        line: "raw",
        samples: 100,
        // fill: true,
        label: $sin(x)$
      )
    })
})