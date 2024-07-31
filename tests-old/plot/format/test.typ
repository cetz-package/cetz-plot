#set page(width: auto, height: auto)
#import "/tests/helper.typ": *
#import cetz: draw
#import cetz-plot: plot

#let data = ((-calc.pi, -1), (+calc.pi, +1))

#test-case({
  plot.plot(
    size: (8, 4),
    x-min: -2 * calc.pi,
    x-max: +2 * calc.pi,
    x-tick-step: calc.pi/2,
    x-format: plot.formats.multiple-of, {
    plot.add(data)
  })
})

#test-case({
  plot.plot(
    size: (8, 4),
    x-min: -2,
    x-max: +2,
    x-tick-step: 1/3,
    x-format: plot.formats.fraction, {
    plot.add(data)
  })
})

#test-case({
  plot.plot(
    size: (8, 4),
    x-min: -2,
    x-max: +2,
    x-tick-step: 1/3,
    x-format: plot.formats.fraction.with(denom: 33), {
    plot.add(data)
  })
})
