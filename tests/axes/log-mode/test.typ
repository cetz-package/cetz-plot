

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
    // y-format: "sci",
    x-min: 0, x-max: 2,
    y-min: 0, y-max: 10,
    // y-min: 0,
    {
      plot.add(domain: (0, 2), x => {calc.pow(10, x)})
      plot.add(domain: (0, 2), x => {x+1}, samples: 100)
    }
  )
}))