#import "/src/cetz.typ" as cetz
#import "/src/lib.typ" as cetz-plot

// String that gets prefixed to every example code
// for compilation only!
#let example-preamble = "import cetz.draw: *; import cetz-plot: *;"
#let example-scope = (cetz: cetz, cetz-plot: cetz-plot)


/// Render an example from a string
/// - source (string, raw): Example source code
/// - args (arguments): Arguments passed down to the canvas
/// - vertical (boolean): If true, show the code below the canvas
#let example(source, ..args, vertical: false) = {
  if type(source) == content {
    source = source.text
  }

  let radius = .25cm
  let border = 1pt + gray
  let canvas-background = yellow.lighten(95%)

  let picture = cetz.canvas(
    eval(
      example-preamble + source,
      scope: example-scope
    ),
    ..args
  )
  let source = box(
    raw(
      source,
      lang: "typc"
    ),
    width: 100%
  )

  block(
    if vertical {
      align(
        center,
        stack(
          dir: ttb,
          spacing: 1em,
          block(
            width: 100%,
            clip: true,
            radius: radius,
            stroke: border,
            table(
              columns: 1,
              stroke: none,
              fill: (c,r) => (canvas-background, white).at(r),
              picture,
              align(left, source)
            )
          ),
        )
      )
    } else {
      block(
        table(
          columns: 2,
          stroke: none,
          fill: (canvas-background, white),
          align: (center + horizon, left),
          picture,
          source
        ),
        width: 100%,
        radius: radius,
        clip: true,
        stroke: border
      )
  }, breakable: false)
}
