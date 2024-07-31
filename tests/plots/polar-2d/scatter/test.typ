// #set page(width: auto, height: auto)
#import "/tests/helper.typ": *

#test-case({
  cetz.draw.set-style(axes:( fill: luma(91.37%).transparentize(90%)))
  cetz-plot.plot(
    axis-style: cetz-plot.axis-style.polar-2d,
    size: (16,9),

    x-tick-step: calc.pi / 4,
    x-minor-tick-step: calc.pi / 16,
    x-grid: "both",
    x-min: 0, x-max: 2 * calc.pi,
    x-format: cetz-plot.axes.format.multiple-of,

    y-min: -1, y-max: 1, y-tick-step: 0.5, y-minor-tick-step: 0.1,
    y-grid: "both",
    {
      cetz.plot.add(
        calc.sin, 
        domain: (0,2*calc.pi), 
        label: $y=x$, 
        line: "raw",
        samples: 50
      )

      cetz.plot.add(
        (t)=>calc.pow(calc.sin(t),2),
        domain: (0, 2* calc.pi), 
        line: "raw",
        samples: 50,
        label: $sin^2 (x)$
      )
    }
  )
})