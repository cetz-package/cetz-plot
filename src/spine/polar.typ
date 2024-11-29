#import "/src/cetz.typ"
#import "/src/axis.typ"
#import "/src/ticks.typ"
#import "/src/style.typ": prepare-style, get-axis-style, default-style
#import "/src/spine/util.typ": cartesian-axis-projection

#import cetz: vector, draw

/// Polar frame
#let polar(projections: none, name: none, ..style) = {
  assert(projections.len() == 1,
    message: "Unexpected number of projections!")

  return (
    name: name,
    draw: (ptx) => {
      let proj = projections.first()
      let angular = proj.axes.at(0)
      let distal = proj.axes.at(1)

      let (origin, start, mid, stop) = (proj.transform)(
        (angular.min, distal.min),
        (angular.min, distal.max),
        ((angular.min + angular.max) / 2, distal.max),
        (angular.max, distal.max),
      )
      start = start.map(calc.round.with(digits: 6))
      stop = stop.map(calc.round.with(digits: 6))

      let radius = vector.dist(origin, start)

      let style = prepare-style(ptx, cetz.styles.resolve(ptx.cetz-ctx.style,
        root: "axes", merge: style.named(), base: style.default-style))
      let angular-style = get-axis-style(ptx, style, "angular")
      let distal-style = get-axis-style(ptx, style, "distal")

      let r-padding = angular-style.padding.first()
      let r-start = origin
      let r-end = vector.add(origin, (0, radius))
      draw.line(r-start, (rel: (0, radius + r-padding)), stroke: distal-style.stroke)
      if "computed-ticks" in distal {
        // TODO
        ticks.draw-distal-grid(proj, distal.computed-ticks, distal-style)
        //ticks.draw-cartesian(r-start, r-end, distal.computed-ticks, distal-style)
      }

      if start == stop {
        draw.circle(origin, radius: radius + r-padding,
          stroke: angular-style.stroke,
          fill: angular-style.fill)
      } else {
        // Apply padding to all three points
        (start, mid, stop) = (start, mid, stop).map(pt => {
          vector.add(pt, vector.scale(vector.norm(vector.sub(pt, origin)), r-padding))
        })

        draw.arc-through(start, mid, stop,
          stroke: angular-style.stroke,
          fill: angular-style.fill,
          mode: "PIE")
      }
      if "computed-ticks" in angular {
        ticks.draw-angular-grid(proj, angular.computed-ticks, angular-style)
        // TODO
      }
    },
  )
}
