#set page(width: auto, height: auto)
#import "/tests/helper.typ": *

#test-case({
  // cetz.draw.set-style(axes:( fill: luma(85%)))
  cetz-plot.plot(
    axis-style: cetz-plot.orthorect-2d,
    size: (5,5),
    // x-min: 1, x-max: 100, x-tick-step: 1, x-minor-tick-step: 1,
    // x-mode: "log",
    x-grid: "both",
    y-min: 0, y-max: 10,
    y-grid: "both",
    {
      cetz.plot.add((x)=>x, domain: (0,10), label: $y=x$, line: "raw")
    }
  )
})