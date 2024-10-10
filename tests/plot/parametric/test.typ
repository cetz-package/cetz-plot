#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

/* Simple plot */
#test-case({
  import draw: *

  plot.plot(size: (4, 4),
    x-tick-step: 1,
    y-tick-step: 1,
  {
    plot.add((t) => (calc.cos(t * 1rad), calc.sin(t * 1rad)),
             domain: (0, 2 * calc.pi))
  })
})

/* Test clipping */
#test-case({
  import draw: *

  plot.plot(size: (4, 4),
    x-min: -1, x-max: 1,
    y-min: -1, y-max: 1,
    x-tick-step: 1,
    y-tick-step: 1,
  {
    plot.add((t) => (calc.cos(t * 1rad) + .5, calc.sin(t * 1rad)),
             domain: (0, 2 * calc.pi))
    plot.add((t) => (calc.cos(t * 1rad) - .5, calc.sin(t * 1rad)),
             domain: (0, 2 * calc.pi))
    plot.add((t) => (calc.cos(t * 1rad), calc.sin(t * 1rad) + .5),
             domain: (0, 2 * calc.pi))
    plot.add((t) => (calc.cos(t * 1rad), calc.sin(t * 1rad) - .5),
             domain: (0, 2 * calc.pi))
  })
})

/* Test filling */
#test-case({
  import draw: *

  plot.plot(size: (4, 4),
    x-tick-step: 1,
    y-tick-step: 1,
  {
    plot.add((t) => (calc.cos(t * 1rad), calc.sin(t * 1rad)),
             domain: (0, 2 * calc.pi),
             fill: true)
  })
})

/* Test clipping + filling */
#test-case({
  import draw: *

  plot.plot(size: (4, 4),
    x-min: -1, x-max: 1,
    y-min: -1, y-max: 1,
    x-tick-step: 1,
    y-tick-step: 1,
  {
    plot.add((t) => (calc.cos(t * 1rad) + .5, calc.sin(t * 1rad)),
             domain: (0, 2 * calc.pi), fill: true, fill-type: "shape")
    plot.add((t) => (calc.cos(t * 1rad) - .5, calc.sin(t * 1rad)),
             domain: (0, 2 * calc.pi), fill: true, fill-type: "shape")
    plot.add((t) => (calc.cos(t * 1rad), calc.sin(t * 1rad) + .5),
             domain: (0, 2 * calc.pi), fill: true, fill-type: "shape")
    plot.add((t) => (calc.cos(t * 1rad), calc.sin(t * 1rad) - .5),
             domain: (0, 2 * calc.pi), fill: true, fill-type: "shape")
  })
})

/* Test clipping + filling */
#test-case({
  import draw: *

  plot.plot(size: (4, 4),
    x-tick-step: 1,
    y-tick-step: 1,
    y-max: .5, y-min: -.5,
    x-max: 1, x-min: -1,
    {
      let f(t, off: 0) = {(calc.cos(t) / (calc.pow(calc.sin(t), 2) + 1) + off,
                           calc.cos(t) * calc.sin(t) / (calc.pow(calc.sin(t), 2) + 1) + off)}
      plot.add(samples: 50,
        domain: (0, 2 * calc.pi), f, fill:true, fill-type: "shape")
      plot.add(samples: 50,
        domain: (0, 2 * calc.pi), f.with(off: .4), fill:true, fill-type: "shape")
      plot.add(samples: 50,
        domain: (0, 2 * calc.pi), f.with(off: -.4), fill:true, fill-type: "shape")
    })
})
