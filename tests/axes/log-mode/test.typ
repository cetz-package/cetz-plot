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
    x-min: 0.00001, x-max: 10,
    y-min: -10, y-max: 10,
    {
      plot.add(domain: (0.00001, 10), x => {calc.pow(10, x)}, mark: "o")
      plot.add(domain: (0.00001, 10), x => x, samples: 100)
    }
  )
}))