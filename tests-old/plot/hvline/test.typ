#set page(width: auto, height: auto)
#import "/src/lib.typ": *
#import "/src/cetz.typ": *
#import "/tests/helper.typ": *

/* Empty plot */
#test-case({
  import draw: *

  plot.plot(size: (1, 1),
    x-tick-step: none,
    y-tick-step: none,
  {
    plot.add-vline(0)
    plot.add-hline(0)
    plot.add(((0,0), (1, 0)))
  })
})

/* Line plot + h/v line */
#test-case({
  import draw: *

  plot.plot(size: (4, 4),
    x-tick-step: none,
    y-tick-step: none,
  {
    plot.add-vline(0)
    plot.add-hline(0)
    plot.add(((-1, -1), (1,1)))
  })
})

/* Line plot + Multiple h/v lines */
#test-case({
  import draw: *

  plot.plot(size: (4, 4),
    x-tick-step: none,
    y-tick-step: none,
  {
    plot.add-vline(-.1, 0, .1)
    plot.add-hline(-.1, 0, .1)
    plot.add(((-2, -2), (2,2)))
  })
})

/* Clipped h/v lines */
#test-case({
  import draw: *

  plot.plot(size: (4, 4),
    x-tick-step: none,
    y-tick-step: none,
    x-min: 0, x-max: 2,
    y-min: 0, y-max: 2,
  {
    plot.add-vline(-.1, 1, 3)
    plot.add-hline(-.1, 1, 3)
  })
})
