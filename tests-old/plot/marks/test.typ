#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ" as cetz-plot
#import "/tests/helper.typ": *

// cetz-plot #13
#test-case({
  import cetz-plot: plot

  let axis-options = (("x", "y"), ("x2", "y"), ("x", "y2"), ("x2", "y2"))

  plot.plot(
    size: (5,5),
     x-min: 0,  x-max: 1,
     y-min: 0,  y-max: 1,
    x2-min: 1, x2-max: 0,
    y2-min: 1, y2-max: 0,
    for axes in axis-options {
      plot.add(
        axes: axes,
        mark: "o",
        ((0.1,0.1), (0.4,0.4))
      )
    }
  )
})
