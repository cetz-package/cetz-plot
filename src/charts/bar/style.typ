#let barchart-default-style = (
  axes: (
    // Hide ticks
    tick: (length: 0),

    // Show a dotted grid
    grid: (stroke: (dash: "dotted")),

    // Hide top and right axis
    top: (hidden: true),
    right: (hidden: true),
  ),

  error: (
    whisker-size: .25,
  ),
)
