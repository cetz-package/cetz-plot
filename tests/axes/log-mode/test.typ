

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
    y-mode: "log",
    y-grid: "both",
    y-format: "log",
    y-tick-step: 1,
    y-minor-tick-step: 1,
    y-min: 0, y-max: 4,
    
    x-mode: "log",
    x-grid: "both",
    x-format: "log",
    x-tick-step: 1,
    x-minor-tick-step: 1,
    x-min: 0.00001, x-max: 4,
    
    {
      plot.add(domain: (0.00001, 10), x => {calc.pow(10, x)}, mark: "o")
      plot.add(domain: (0.00001, 10), x => {x}, samples: 100)
    }
  )
}))