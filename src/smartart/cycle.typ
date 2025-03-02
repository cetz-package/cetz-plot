#import "/src/cetz.typ" as cetz: draw, styles, palette, coordinate, util.resolve-number, vector

#import "common.typ": *

#let cycle-basic-default-style = (
  stroke: auto,
  fill: auto,
  spacing: 0.2em,
  steps: (
    stroke: none,
    fill: none,
    radius: 0.2em,
    padding: 0.6em,
    max-width: 5em,
    shape: "rect"
  ),
  arrows: (
    stroke: none,
    fill: "steps",
    thickness: 1em,
    double: false,
    curved: true
  )
)

#let basic(
  steps,
  arrow-style: auto,
  step-style: palette.red,
  equal-width: false,
  equal-height: false,
  ccw: false,
  radius: 2,
  offset-angle: 0deg,
  name: none,
  ..style
) = {
  draw.group(name: name, ctx => {
    draw.anchor("default", (0, 0))

    let style = styles.resolve(
      ctx.style,
      merge: style.named(),
      root: "cycle-basic",
      base: cycle-basic-default-style,
    )

    let spacing = resolve-number(ctx, style.spacing)

    let step-style-at = _get-style-at-func(step-style)
    let arrow-style-at = _get-style-at-func(arrow-style)

    let (
      sizes,
      largest-width,
      highest-height
    ) = _get-steps-sizes(steps, ctx, style, step-style-at)

    let angle-step = 360deg / steps.len()
    if not ccw {
      angle-step *= -1
    }

    for (i, step) in steps.enumerate() {
      let angle = angle-step * i + 90deg + offset-angle
      let pos = (angle, radius)

      let step-style = style.steps + step-style-at(i)
      let padding = resolve-number(ctx, step-style.padding)

      let (w, h) = sizes.at(i)
      if equal-width {
        w = largest-width
      }
      if equal-height {
        h = highest-height
      }
      let step-name = "step-" + str(i)

      _draw-step(ctx, step, pos, step-style, step-name, w, h)
    }

    for i in range(steps.len()) {
      let angle = angle-step * i + 90deg + offset-angle

      let arrow-style = style.arrows + arrow-style-at(i)
      let arrow-stroke = arrow-style.stroke
      let arrow-fill = arrow-style.fill
      let arrow-thickness = arrow-style.thickness

      if arrow-fill == "steps" {
        let s1 = style.steps + step-style-at(i)
        let s2 = style.steps + step-style-at(i + 1)
        arrow-fill = gradient.linear(s1.fill, s2.fill).sample(50%)
      }

      let start-angle = angle + angle-step * 0.2
      let end-angle = angle + angle-step * 0.8

      let a1 = angle
      let a2 = angle + angle-step / 2
      let a3 = angle + angle-step
      let n(a) = {
        if a < -180deg {
          a += 360deg
        } else if a > 180deg {
          a -= 360deg
        }
        return a
      }
      a1 = n(a1)
      a2 = n(a2)
      a3 = n(a3)
      let pts = (
        (a1, radius),
        (a2, radius),
        (a3, radius),
      )
      if not ccw {
        pts = pts.rev()
      }
      draw.hide(draw.arc-through(
        ..pts,
        name: "arc-" + str(i)
      ))
      draw.intersections(
        "i-" + str(i),
        "step-" + str(i),
        "arc-" + str(i)
      )
      draw.intersections(
        "j-" + str(i),
        "step-" + str(calc.rem(i + 1, steps.len())),
        "arc-" + str(i)
      )

      draw.get-ctx(ctx => {
        let (_, p1) = coordinate.resolve(ctx, "i-" + str(i) + ".0")
        let (_, p2) = coordinate.resolve(ctx, "j-" + str(i) + ".0")
        let start-angle = calc.atan2(p1.at(0), p1.at(1))
        let end-angle = calc.atan2(p2.at(0), p2.at(1))
        if ccw != (start-angle < end-angle) {
          if ccw {
            end-angle += 360deg
          } else {
            end-angle -= 360deg
          }
        }
        let angle-d = end-angle - start-angle

        let prev = "step-" + str(i)
        start-angle += angle-d * 0.1
        end-angle -= angle-d * 0.1
        let arrow-name = "arrow-" + str(i)

        let marks = (end: "straight")
        if arrow-style.double {
          marks.insert("start", "straight")
        }

        let arrow-thickness = arrow-thickness
        if arrow-thickness != none {
          arrow-thickness = resolve-number(ctx, arrow-thickness)
        }

        // Curved
        if arrow-style.curved {
          // Thin arrow
          if arrow-thickness == none {
            draw.arc-through(
              (start-angle, radius),
              ((start-angle + end-angle) / 2, radius),
              (end-angle, radius),
              stroke: arrow-stroke,
              mark: marks,
              name: arrow-name
            )
          
          // Thick arrow
          } else {
            _draw-arc-arrow(
              start-angle,
              end-angle,
              radius,
              arrow-thickness,
              arrow-fill,
              arrow-stroke,
              double: arrow-style.double,
              name: arrow-name
            )
          }
        
        // Straight
        } else {
          let p1 = (start-angle, radius)
          let p2 = (end-angle, radius)
          if arrow-thickness == none {
            draw.line(
              p1, p2,
              stroke: arrow-stroke,
              mark: marks,
              name: arrow-name
            )
          } else {
            _draw-arrow(
              p1, p2,
              arrow-thickness,
              arrow-fill,
              arrow-stroke,
              double: arrow-style.double,
              name: arrow-name
            )
          }
        }
      })
    }
  })
}