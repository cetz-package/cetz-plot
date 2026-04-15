#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import smartart: cycle
#import "/tests/helper.typ": *

#let colors = gradient.linear(rgb("FFCCE5"), rgb("660033"))

// Gradient + variable number of steps
#let make-test-case(func, min: 2, max: 5) = test-case(
  func,
  args: range(min, max + 1).map(i => (
    steps: range(1, i + 1).map(str)
  ))
)

// Default
#make-test-case(args => {
  import draw: *
  cycle.basic(args.steps)
}, max: 6)

#pagebreak()

#let steps = ([A], [B], [C], [D], [E])

#let defaults() = draw.set-style(
  cycle-basic: (
    steps: (
      fill: rgb("#156082"),
      stroke: none
    ),
    arrows: (
      fill: rgb("#156082"),
      stroke: rgb("#156082")
    )
  )
)
// Thin curved
#test-case({
  defaults()
  smartart.cycle.basic(
    steps,
    arrows: (
      thickness: none
    ),
    step-style: none
  )
})

// No frame
#test-case({
  defaults()
  smartart.cycle.basic(
    steps.map(text.with(fill: black)),
    step-style: none,
    steps: (shape: none)
  )
})

// Square frame + thick curved arrows
#test-case({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    arrows: (
      fill: rgb("#AAB6C1"),
      stroke: none
    )
  )
})

// Circle frame + thick straight arrows
#test-case({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    steps: (
      shape: "circle"
    ),
    arrows: (
      fill: rgb("#AAB6C1"),
      stroke: none,
      curved: false
    )
  )
})

// Circle frame + thin straight arrows
#test-case({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    steps: (
      shape: "circle"
    ),
    arrows: (
      thickness: none,
      curved: false
    )
  )
})

// Square frame + thick double straight arrows
#test-case({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    arrows: (
      fill: rgb("#AAB6C1"),
      stroke: none,
      curved: false,
      double: true
    )
  )
})

// Square frame + thick double curved arrows
#test-case({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    arrows: (
      fill: rgb("#AAB6C1"),
      stroke: none,
      curved: true,
      double: true
    )
  )
})

// Square frame + thick counter clockwise curved arrows
#test-case({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    ccw: true
  )
})

// Square frame + thin double straight arrows
#test-case({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    arrows: (
      thickness: none,
      curved: false,
      double: true
    )
  )
})

#pagebreak()

// Radius
#test-case({
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    radius: 3
  )
})

#let steps = ([Short], [Longer], [Very long], [High\ step\ ...])

// Equal-width / Equal-height
#test-case(args => {
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    equal-width: args.eq-w,
    equal-height: args.eq-h
  )
}, args: (
  (eq-w: false, eq-h: false),
  (eq-w: true, eq-h: false),
  (eq-w: false, eq-h: true),
  (eq-w: true, eq-h: true)
))

// Steps max-width
#test-case(args => {
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    steps: (
      max-width: args.max-w
    )
  )
}, args: (
  (max-w: 5em),
  (max-w: 8em),
))

// Offset angle
#test-case(args => {
  defaults()
  smartart.cycle.basic(
    steps,
    step-style: none,
    offset-angle: args.angle,
    ccw: args.ccw
  )
}, args: (
  (angle: 0deg, ccw: false),
  (angle: 15deg, ccw: false),
  (angle: -20deg, ccw: false),
  (angle: 0deg, ccw: true),
  (angle: 15deg, ccw: true),
  (angle: -20deg, ccw: true),
))