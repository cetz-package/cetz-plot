#set page(width: auto, height: auto, margin: 1cm)
#import "/tests/helper.typ": *

#test-case({

  // Sample function manually
  let data = range(0,int(31)).map((t)=>{
    (
      2 * calc.pi * t/30, // x
      calc.pow(calc.sin(2 * calc.pi * t/30),2), // y
      0.1, // xerr
      0.02, // yerr
    )
  })

  cetz-plot.plot(
    axis-style: cetz-plot.axis-style.orthorect-2d,
    size: (12,7),

    x-tick-step: calc.pi / 4,
    x-minor-tick-step: calc.pi / 16,
    x-grid: "both",
    x-min: 0, x-max: 2 * calc.pi,
    x-format: cetz-plot.axes.format.multiple-of,

    y-tick-step: 0.5, y-minor-tick-step: 0.1,
    y-grid: "both",
    {

    cetz-plot.add.fill-between(
      data.map(it=>(it.at(0), it.at(1)+it.at(2))),
      data.map(it=>(it.at(0), it.at(1)-it.at(2))),
      style: (stroke: none),
      label: [95% C.I]
    )

    }
  )

})