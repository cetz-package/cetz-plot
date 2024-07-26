

#set page(width: auto, height: auto)

#import "/tests/helper.typ": *
#import "/src/lib.typ": *
#import cetz: draw, canvas
#import cetz-plot: axes,

#box(stroke: 2pt + red, canvas({
  import draw: *

  plot.plot(
    size: (9, 6), 
    axis-style: "scientific", 
    y-mode: "log", y-base: 10,
    // x-mode: "log",
    y-format: "sci",
    x-min: 1, x-max: 100,
    y-min: 1, y-max: 10000, y-tick-step: 1, y-minor-tick-step: 1,
    y-grid: "both",
    {
      plot.add(domain: (0.3, 10), x => {calc.pow(10, x)})
      plot.add(domain: (0, 100), x => {x}, samples: 10)
    }
  )
}))