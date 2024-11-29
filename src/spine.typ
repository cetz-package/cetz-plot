#import "/src/cetz.typ"
#import cetz: vector, draw

#import "/src/ticks.typ"
#import "/src/projection.typ"
#import "/src/axis.typ"
#import "/src/style.typ": prepare-style, get-axis-style, default-style
#import "/src/spine/scientific.typ": cartesian-scientific
#import "/src/spine/util.typ": cartesian-axis-projection

/// Default schoolbook style
#let default-style-schoolbook = cetz.util.merge-dictionary(default-style, (
  mark: (end: "straight"),
  padding: (.1cm, 1em),

  tick: (
    offset: -.1cm,
    length: .2cm,
    minor-offset: -.05cm,
    minor-length: .1cm,
  ),
))

///
#let schoolbook(projections: none, name: none, zero: (0, 0), ..style) = {
  return (
    name: name,
    draw: (ptx) => {
      let proj = projections.at(0)
      let axes = proj.axes
      let x = axes.at(0)
      let y = axes.at(1)
      let z = axes.at(2, default: none)

      let style = prepare-style(ptx, cetz.styles.resolve(ptx.cetz-ctx.style,
        root: "axes", merge: style.named(), base: default-style-schoolbook))
      let x-style = get-axis-style(ptx, style, "x")
      let y-style = get-axis-style(ptx, style, "y")

      let zero-x = calc.max(x.min, calc.min(0, x.max))
      let zero-y = calc.max(y.min, calc.min(0, y.max))
      let zero-pt = (
        calc.max(x.min, calc.min(zero.at(0), x.max)),
        calc.max(y.min, calc.min(zero.at(1), y.max)),
      )

      let (zero, min-x, max-x, min-y, max-y) = (proj.transform)(
        zero-pt,
        vector.add(zero-pt, (x.min, zero-y)), vector.add(zero-pt, (x.max, zero-y)),
        vector.add(zero-pt, (zero-x, y.min)), vector.add(zero-pt, (zero-x, y.max)),
      )

      let x-padding = x-style.padding
      if type(x-padding) != array {
        x-padding = (x-padding, x-padding)
      }

      let y-padding = y-style.padding
      if type(y-padding) != array {
        y-padding = (y-padding, y-padding)
      }

      let outset-lo-x = (x-padding.at(0), 0)
      let outset-hi-x = (x-padding.at(1), 0)
      let outset-lo-y = (0., y-padding.at(0))
      let outset-hi-y = (0., y-padding.at(1))
      let outset-min-x = vector.scale(outset-lo-x, -1)
      let outset-max-x = vector.scale(outset-hi-x, +1)
      let outset-min-y = vector.scale(outset-lo-y, -1)
      let outset-max-y = vector.scale(outset-hi-y, +1)


      draw.on-layer(x-style.axis-layer, {
        draw.line((rel: outset-min-x, to: min-x),
                  (rel: outset-max-x, to: max-x),
          mark: x-style.mark,
          stroke: x-style.stroke)
      })
      if "computed-ticks" in x {
        //ticks.draw-cartesian-grid(grid-proj, grid-dir, ax, ax.computed-ticks, style)
        let tick-proj = cartesian-axis-projection(x, min-x, max-x)
        ticks.draw-cartesian(tick-proj, (0,+1), x.computed-ticks, x-style)
      }

      draw.on-layer(y-style.axis-layer, {
        draw.line((rel: outset-min-y, to: min-y),
                  (rel: outset-max-y, to: max-y),
          mark: y-style.mark,
          stroke: y-style.stroke)
      })
      if "computed-ticks" in y {
        //ticks.draw-cartesian-grid(min-y, max-y, 1, y, y.computed-ticks, min-x, max-x, y-style)
        let tick-proj = cartesian-axis-projection(y, min-y, max-y)
        ticks.draw-cartesian(tick-proj, (+1,0), y.computed-ticks, y-style)
      }
    }
  )
}

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
