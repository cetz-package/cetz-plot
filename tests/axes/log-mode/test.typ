#set page(width: auto, height: auto)

#import "/tests/helper.typ": *
#import "/src/lib.typ": *
#import cetz: draw, canvas
#import cetz-plot: axes,

#test-case({
  import draw: *

  plot.plot(
    size: (9, 6), 
    axis-style: "scientific", 
    y-mode: "log", y-base: 10,
    y-format: "sci",
    x-min: 1, x-max: 10, x-tick-step: 1,
    y-min: 1, y-max: 10000, y-tick-step: 1, y-minor-tick-step: 1,
    x-grid: "both",
    y-grid: "both",
    {
      plot.add(
        domain: (0, 10), 
        x => {calc.pow(10, x)},
        samples: 100, 
        line: "raw",
        label: $y=10^x$
      )
      plot.add(
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

// Bode plot test
#box(stroke: 2pt + red,{
  canvas({
    import draw: *
    cetz.draw.set-style(
      grid: (stroke: (paint: luma(83.33%), thickness: 1pt, dash: "dotted")),
      minor-grid: (stroke: (paint: luma(83.33%), thickness: 0.5pt, dash: "dotted")),
    )
    plot.plot(
      size: (16, 6), 
      axis-style: "scientific", 
      x-format: none, x-label: none,
      x-mode: "log",
      x-min: 0.01, x-max: 100, x-tick-step: 1, x-minor-tick-step: 1,
      y-label: [Magnitude ($upright(d B)$)],
      y-min: -40, y-max: 10, y-tick-step: 10, 
      x-grid: "both",
      y-grid: "both",
      {
        plot.add(domain: (0.01, 100), x => {0})
      }
    )
  })
  canvas({
    import draw: *
      cetz.draw.set-style(
      grid: (stroke: (paint: luma(83.33%), thickness: 1pt, dash: "dotted")),
      minor-grid: (stroke: (paint: luma(83.33%), thickness: 0.5pt, dash: "dotted")),
    )
    plot.plot(
      size: (16, 6), 
      axis-style: "scientific", 
      x-mode: "log",
      x-min: 0.01, x-max: 100, x-tick-step: 1, x-minor-tick-step: 1,
      x-label: [Frequency ($upright(r a d)\/s$)],
      y-label: [Phase ($upright(d e g)$)],
      y-min: -90, y-max: 0, y-tick-step: 45, 
      x-grid: "both",
      y-grid: "both",
      {
        plot.add(domain: (0.01, 100), x => {-40})
      }
    )
  })
})

// Column chart test
#box(stroke: 2pt + red, canvas({
  import draw: *

  plot.plot(
    size: (9, 6), 
    axis-style: "scientific", 
    y-mode: "log", y-base: 10,
    y-format: "sci",
    x-min: -0.5, x-max: 4.5, x-tick-step: 1,
    y-min: 0.1, y-max: 10000, y-tick-step: 1, y-minor-tick-step: 1,
    x-grid: "both",
    y-grid: "both",
    {
      plot.add-bar(
        (1, 10, 100, 1000, 10000).enumerate().map(((x,y))=>{(x,y)}),
        bar-width: 0.8,
      )
    }
  )
}))

// Scatter plot test
#box(stroke: 2pt + red, canvas({
  import draw: *

  plot.plot(
    size: (9, 6), 
    axis-style: "scientific", 
    y-mode: "log", y-base: 100,
    y-format: "sci",
    x-min: -0.5, x-max: 4.5, x-tick-step: 1,
    y-min: 0.1, y-max: 10000, y-tick-step: 1, y-minor-tick-step: 10,
    x-grid: "both",
    y-grid: "both",
    {
      plot.add(
        ((0, 1),(1,2),(1,3),(2, 100),(2,150),(3, 1000),),
        style: (stroke: none),
        mark: "o"
      )
      plot.annotate({
          rect((0, 1), (calc.pi, 10), fill: rgb(50,50,200,50))
          content((2, 3), [Annotation])
      })
      plot.annotate({
          rect((0, 1000), (calc.pi, 10000), fill: rgb(50,50,200,50))
          content((2, 3000), [Annotation])
      })
    }
  )
}))

// Box plot test
#box(stroke: 2pt + red, canvas({
  import draw: *

  plot.plot(
    size: (9, 6), 
    axis-style: "scientific", 
    y-mode: "log", y-base: 10,
    y-format: "sci",
    x-min: -0.5, x-max: 2.5, x-tick-step: 1,
    y-min: 0.1, y-max: 15000, y-tick-step: 1, y-minor-tick-step: 1,
    x-grid: "both",
    y-grid: "both",
    {
      plot.add-boxwhisker(
        (
          (x: 0, min: 1, q1: 10, q2: 100, q3: 1000, max: 10000),
          (x: 1, min: 100, q1: 200, q2: 300, q3: 400, max: 500),
          (x: 2, min: 10, q1: 100, q2: 500, q3: 1000, max: 5000),
        ),
      )
    }
  )
}))
