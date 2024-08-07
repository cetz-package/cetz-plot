#set page(width: auto, height: auto)
#import "/tests/helper.typ": *
#import cetz: draw
#import cetz-plot: plot

#let dom = (domain: (0, 2 * calc.pi))
#let fn(x, offset: 0) = {calc.sin(x) + offset}

#for pos in ("north", "south", "west", "east",
             "north-east", "north-west",
             "south-east", "south-west",) {
  test-case({
    import draw: *

    plot.plot(size: (2, 2),
      x-tick-step: none,
      y-tick-step: none,
      legend: pos,
      {
        plot.add(..dom, fn, label: $ f(x) $)
      })
  })
}

#for pos in ("inner-north", "inner-south", "inner-west", "inner-east",
             "inner-north-east", "inner-north-west",
             "inner-south-east", "inner-south-west",) {
  test-case({
    import draw: *

    plot.plot(size: (4, 2),
      x-tick-step: none,
      y-tick-step: none,
      legend: pos,
      {
        plot.add(..dom, fn, label: $ f(x) $)
      })
  })
}

#test-case({
  plot.plot(size: (4, 2),
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add(..dom, fn, label: $ f_1(x) $)
      plot.add(..dom, fn.with(offset: .1), label: $ f_2(x) $)
      plot.add(..dom, fn.with(offset: .2), label: $ f_3(x) $)
    })
})

#test-case({
  plot.plot(size: (4, 2),
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add(samples: 10, ..dom, fn, mark: "o", label: $ f(x) $)
      plot.add(samples: 10, ..dom, fn.with(offset: .1), mark: "x", fill: true, label: $ f_2(x) $)
      plot.add(samples: 10, ..dom, fn.with(offset: .2), mark: "|", style: (stroke: none), label: $ f_3(x) $)
    })
})

#test-case({
  plot.plot(size: (4, 2),
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add-fill-between(..dom, fn, fn.with(offset: .5), label: $ f(x) $)
    })
})

#test-case({
  plot.plot(size: (4, 2),
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add-hline(0, label: $ f(x) $)
      plot.add-vline(0, label: $ f(x) $)
    })
})

#test-case({
  plot.plot(size: (4, 2),
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add-contour(x-domain: (-1, 1), y-domain: (-1, 1),
        (x, y) => x, z: 0, op: "<=", label: $ f(x) $)
      plot.add-contour(x-domain: (-1, 1), y-domain: (-1, 1),
        (x, y) => x, z: 0, fill: true, label: $ f(x) $)
    })
})

#test-case({
  import draw: *

  let box1 = (
    x:  1,
    outliers: (7, 65, 69),
    min: 15,
    q1: 25,
    q2: 35,
    q3: 50,
    max: 60)

  plot.plot(size: (4, 2),
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add-boxwhisker(box1, label: [Box])
    })
})

#test-case({
  import draw: *

  set-style(legend: (item: (preview: (width: .4), spacing: .7),
    orientation: ltr, default-position: "north"))

  plot.plot(size: (4, 2),
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add(samples: 10, ..dom, fn, mark: "o", label: $ f(x) $)
      plot.add(samples: 10, ..dom, fn.with(offset: .1), mark: "x", fill: true, label: $ f_2(x) $)
      plot.add(samples: 10, ..dom, fn.with(offset: .2), mark: "|", style: (stroke: none), label: $ f_3(x) $)
    })
})

#test-case({
  import draw: *

  set-style(legend: (item: (preview: (width: .4, height: 1), spacing: 1),
    padding: .1,
    stroke: black,
    fill: white,
    orientation: ltr, default-position: "north"))

  plot.plot(size: (4, 2),
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add(samples: 10, ..dom, fn, mark: "o", label: $ f(x) $)
      plot.add(samples: 10, ..dom, fn.with(offset: .1), mark: "x", fill: true, label: $ f_2(x) $)
      plot.add(samples: 10, ..dom, fn.with(offset: .2), mark: "|", style: (stroke: none), label: $ f_3(x) $)
    })
})

#test-case({
  plot.plot(size: (4, 2),
    axis-style: "school-book",
    legend-style: (offset: (-2.5, 1),
      item: (preview: (margin: .5), spacing: .15),
      fill: white,
      stroke: (paint: black, dash: "dotted"),
      padding: (.1, .5)),
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add(samples: 10, ..dom, fn, mark: "o", label: $ f(x) $)
      plot.add(samples: 10, ..dom, fn.with(offset: .1), mark: "x", fill: true, label: $ f_2(x) $)
      plot.add(samples: 10, ..dom, fn.with(offset: .2), mark: "|", style: (stroke: none), label: $ f_3(x) $)
    })
})

#test-case({
  plot.plot(size: (4,2), x-tick-step: none, y-tick-step: none, {
    plot.add(domain: (0,1), x => x)
    plot.add-legend([Custom 1])
    plot.add-legend([Custom 2], preview: () => {
      import draw: *
      set-style(stroke: blue)
      line((0,0), (1,1))
      line((0,1), (1,0))
    })
  })
})
