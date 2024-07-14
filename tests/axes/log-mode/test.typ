

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
    y-grid: "both",
    y-tick-step: 1,
    y-minor-tick-step: 1,
    y-mode: "log",
    y-format: "sci",
    x-min: 0.00001, x-max: 10,
    y-min: 0, y-max: 4,
    {
      plot.add(domain: (0.00001, 10), x => {calc.pow(10, x)}, mark: "o")
      plot.add(domain: (0.00001, 10), x => {x+1}, samples: 100)
    }
  )
}))