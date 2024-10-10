#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

/* X grid */
#test-case({
  import draw: *

  plot.plot(size: (3, 3),
    x-grid: true,
    x-tick-step: .5,
    y-tick-step: .5,
  {
    plot.add(((0,0), (1,1)))
  })
})

/* X grid */
#test-case({
  import draw: *

  plot.plot(size: (3, 3),
    x-grid: "both",
    x-tick-step: .5,
    x-minor-tick-step: .25,
    y-tick-step: .5,
  {
    plot.add(((0,0), (1,1)))
  })
})

/* Y grid */
#test-case({
  import draw: *

  plot.plot(size: (3, 3),
    y-grid: true,
    x-tick-step: .5,
    y-tick-step: .5,
  {
    plot.add(((0,0), (1,1)))
  })
})

/* Y grid */
#test-case({
  import draw: *

  plot.plot(size: (3, 3),
    y-grid: "both",
    x-tick-step: .5,
    y-tick-step: .5,
    y-minor-tick-step: .25,
  {
    plot.add(((0,0), (1,1)))
  })
})

/* X-Y grid */
#test-case({
  import draw: *

  plot.plot(size: (3, 3),
    x-grid: "both",
    y-grid: "both",
    x-tick-step: .5,
    x-minor-tick-step: .25,
    y-tick-step: .5,
    y-minor-tick-step: .25,
  {
    plot.add(((0,0), (1,1)))
  })
})
