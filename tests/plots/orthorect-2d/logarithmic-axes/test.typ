#set page(width: auto, height: auto, margin: 1cm)
#import "/tests/helper.typ": *

#test-case({

  cetz-plot.plot(
    size: (9, 6), 
    y-mode: "log", y-base: 10,
    y-format: "sci",
    x-min: 1, x-max: 10, x-tick-step: 1,
    y-min: 1, y-max: 10000, y-tick-step: 1, y-minor-tick-step: 1,
    x-grid: "both",
    y-grid: "both",
    {
      cetz-plot.add.xy(
        domain: (0, 10), 
        x => {calc.pow(10, x)},
        samples: 100, 
        line: "raw",
        label: $y=10^x$
      )
      cetz-plot.add.xy(
        domain: (1, 10), 
        x => {x}, 
        samples: 100, 
        line: "raw",
        hypograph: true,
        label: $y=x$
      )
    }
  )

})