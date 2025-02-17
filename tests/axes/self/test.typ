#set page(width: auto, height: auto)
#import "/tests/helper.typ": *
#import cetz: draw
#import cetz-plot: axes, plot

// Schoolbook Axis Styling
#test-case({
  import draw: *

  set-style(axes: (
    stroke: blue,
    padding: .25,
    x: (stroke: red),
    y: (stroke: green, tick: (stroke: blue, length: .3))
  ))
  axes.school-book(size: (6, 6),
    axes.axis(min: -1, max: 1, ticks: (step: 1, minor-step: auto,
      grid: "both")),
    axes.axis(min: -1, max: 1, ticks: (step: .5, minor-step: auto,
      grid: "major")))
})

// Scientific Axis Styling
#test-case({
  import draw: *

  set-style(axes: (stroke: blue))
  set-style(axes: (left: (tick: (stroke: green + 2pt))))
  set-style(axes: (bottom: (tick: (stroke: red, length: .5,
                                   label: (angle: 90deg,
                                           anchor: "east")))))
  set-style(axes: (right: (tick: (label: (offset: .2,
                                          angle: -45deg,
                                          anchor: "north-west"), length: -.1))))
  axes.scientific(size: (6, 6),
    draw-unset: false,
    top: none,
    bottom: axes.axis(min: -1, max: 1, ticks: (step: 1, minor-step: auto,
      grid: "both", format: plot.formats.decimal.with(prefix: $<-$, suffix: $->$))),
    left: axes.axis(min: -1, max: 1, ticks: (step: .5, minor-step: auto,
      grid: false)),
    right: axes.axis(min: -10, max: 10, ticks: (step: auto, minor-step: auto,
      grid: "major")),)
})

// Custom Tick Format
#test-case({
  import draw: *

  axes.scientific(size: (6, 1),
    bottom: axes.axis(min: -2*calc.pi, max: 2*calc.pi, ticks: (
      step: calc.pi, minor-step: auto, format: plot.formats.multiple-of.with(symbol: $pi$),
    )),
    left: axes.axis(min: -1, max: 1, ticks: (step: none, minor-step: none)))
})

// #10 - Minor ticks on reversed axis
#test-case({
  import draw: *

  axes.scientific(size: (6, 1),
    bottom: axes.axis(min: 5, max: -5,
      ticks: (step: 5, minor-step: 1)),
    left: axes.axis(min: -1, max: 1, ticks: (step: none, minor-step: none)))
})
