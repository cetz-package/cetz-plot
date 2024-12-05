#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#let line-data = ((-1,-1), (1,1),)

#let data = (..(for x in range(-360, 360 + 1) {
  ((x, calc.sin(x * 1deg)),)
}))

/* Scientific Style */
#test-case({
  plot.plot(size: (5, 2),
    x-tick-step: 180,
    y-tick-step: 1,
    x-grid: "major",
    y-grid: "major",
    {
      plot.add(data)
    })
})

/* 4-Axes */
#test-case({
  plot.plot(size: (5, 3),
    x-tick-step: 180,
    x-min: -360,
    x-max:  360,
    y-tick-step: 1,
    u-label: none,
    u-min: -90,
    u-max:  90,
    u-tick-step: 45,
    u-minor-tick-step: 15,
    v-label: none,
    v-min: -1.5,
    v-max:  1.5,
    v-tick-step: .5,
    v-minor-tick-step: .1,
    {
      plot.add(data)
      plot.add(data, style: (stroke: blue), axes: ("u", "v"))
    })
})

/* School-Book Style */
#test-case({
  plot.plot(size: (5, 4),
    template: "school-book",
    x-tick-step: 180,
    y-tick-step: 1,
    {
      plot.add(data)
    })
})

/* Clipping */
#test-case({
  plot.plot(size: (5, 4),
    template: "school-book",
    x-min: auto,
    x-max: 350,
    x-tick-step: 180,
    y-min: -.5,
    y-max: .5,
    y-tick-step: 1,
    {
      plot.add(data)
    })
})

/* Palettes */
#test-case({
  plot.plot(size: (5, 4),
    x-label: [Rainbow],
    x-tick-step: none,
    y-label: [Color],
    y-max: 8,
    y-tick-step: none,
    {
      for i in range(0, 7) {
        plot.add(domain: (i * 180, (i + 1) * 180),
          epigraph: true,
          style: plot.palette.rainbow,
          x => calc.sin(x * 1deg))
      }
    })
})

/* Tick Step Calculation */
#test-case({
  plot.plot(size: (12, 4),
    v-format: plot.formats.decimal.with(digits: 4),
    {
      plot.add(((0,0), (1,10)), axes: ("x", "y"))
      plot.add(((0,0), (.1,.01)), axes: ("u", "v"))
    })
})

#test-case({
  plot.plot(size: (12, 4),
    v-format: plot.formats.sci,
    u-format: plot.formats.sci,
    {
      plot.add(((0,0), (30,2500)), axes: ("x", "y"))
      plot.add(((0,0), (.001,.0001)), axes: ("u", "v"))
    })
})

/* Templates */
#test-case(args => {
  plot.plot(size: (4,4), x-tick-step: 90, y-tick-step: 1,
            template: args, {
    plot.add(domain: (0, 360), x => calc.sin(x * 1deg))
  })
}, args: (
  // TODO
  //"scientific", "scientific-auto", "left", "school-book", none
  "scientific", "school-book"
))

/* Manual Axis Bounds */
#let circle-data = range(0, 361).map(
  t => (.5 * calc.cos(t*1deg), .5 * calc.sin(t*1deg)))
#test-case({
  plot.plot(size: (4, 4),
    x-tick-step: 1,
    y-tick-step: 1,
    x-min: -1, x-max: 1,
    y-min: -1, y-max: 1,
    xl-min: -1.5, xl-max: .5,
    xr-min: -.5, xr-max: 1.5,
    yb-min: -1.5, yb-max: .5,
    yt-min: -.5, yt-max: 1.5,
    {
      plot.lin-axis("xl")
      plot.lin-axis("xr")
      plot.lin-axis("yt")
      plot.lin-axis("yb")
      plot.add(circle-data)
      plot.add(circle-data, axes: ("xl", "y"), style: (stroke: green))
      plot.add(circle-data, axes: ("xr", "y"), style: (stroke: red))
      plot.add(circle-data, axes: ("x", "yt"), style: (stroke: blue))
      plot.add(circle-data, axes: ("x", "yb"), style: (stroke: yellow))
    })
})

#test-case({
  plot.plot(size: (4, 4),
    x-tick-step: 1,
    y-tick-step: 1,
    x-min: -1, x-max: 1,
    y-min: -1, y-max: 1,
    xl-min: -1.75, xl-max: .25,
    xr-min: -.25, xr-max: 1.75,
    yb-min: -1.75, yb-max: .25,
    yt-min: -.25, yt-max: 1.75,
    {
      plot.lin-axis("xl")
      plot.lin-axis("xr")
      plot.lin-axis("yt")
      plot.lin-axis("yb")
      plot.add(circle-data)
      plot.add(circle-data, axes: ("xl", "y"), style: (stroke: green))
      plot.add(circle-data, axes: ("xr", "y"), style: (stroke: red))
      plot.add(circle-data, axes: ("x", "yt"), style: (stroke: blue))
      plot.add(circle-data, axes: ("x", "yb"), style: (stroke: yellow))
    })
})

/* Anchors */
#test-case({
  import draw: *

  plot.plot(size: (5, 3), name: "plot",
    x-tick-step: 180,
    y-tick-step: 1,
    x-grid: "major",
    y-grid: "major",
    {
      plot.add(data, fill: true)
      plot.add-anchor("from", (-270, "max"))
      plot.add-anchor("to", (90, "max"))
      plot.add-anchor("lo", (90, 0))
      plot.add-anchor("hi", (90, "max"))
    })

  line((rel: (0, .2), to: "plot.from"),
       (rel: (0, .2), to: "plot.to"),
       mark: (start: "|", end: "|"), name: "annotation")
  content((rel: (0, .1), to: ("annotation.start", 50%, "annotation.end")), $2 pi$, anchor: "south")

  line((rel: (0,  .2), to: "plot.lo"),
       (rel: (0, -.2), to: "plot.hi"),
       mark: (start: ">", end: ">"), name: "amplitude")
})

/* Format tick values */
#test-case({
  plot.plot(size: (6, 4),
    x-tick-step: none,
    x-ticks: (-1, 0, 1),
    x-format: x => $x_(#x)$,
    y-tick-step: none,
    y-ticks: (-1, 0, 1),
    y-format: x => $y_(#x)$,
    u-tick-step: none,
    u-ticks: (-1, 0, 1),
    u-format: x => $x_(2,#x)$,
    v-tick-step: none,
    v-ticks: (-1, 0, 1),
    v-format: x => $y_(2,#x)$,
    {
      plot.add(samples: 2, domain: (-1, 1), x => -x, axes: ("x", "y"))
      plot.add(samples: 2, domain: (-1, 1), x => x, axes: ("u", "v"))
    })
})

// Test plot with anchors only
#test-case({
  import draw: *

  plot.plot(size: (6, 4), name: "plot",
    x-min: -1, x-max: 1, y-min: -1, y-max: 1,
    {
      plot.add-anchor("test", (0,0))
    })

  circle("plot.test", radius: 1)
})

// Test empty plot
#test-case({
  plot.plot(size: (1, 1), {})
})

// Some axis styling
#test-case({
  import draw: *

  set-style(axes: (
    padding: .1,
    tick: (
      length: -.1,
    ),
    y: (
      stroke: (paint: red),
      tick: (
        stroke: auto,
      )
    ),
    x: (
      stroke: (paint: blue, thickness: 2pt),
      tick: (
        stroke: auto,
      )
    ),
  ))

  plot.plot(size: (6, 4), axis-style: "scientific-auto", {
    plot.add(line-data)
  })

  set-origin((7, 0))

  set-style(axes: (
    overshoot: .5,
    x: (
      padding: 1,
      overshoot: -.5,
      stroke: blue,
    ),
    y: (
      stroke: red,
    )
  ))
  plot.plot(size: (6, 4), axis-style: "school-book",
    x-tick-step: none,
    y-tick-step: none,
  {
    plot.add(line-data)
  })
})
