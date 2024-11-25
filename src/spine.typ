#import "/src/cetz.typ"
#import cetz: vector, draw

#import "/src/ticks.typ"
#import "/src/projection.typ"

/// Default axis style
///
/// #show-parameter-block("tick-limit", "int", default: 100, [Upper major tick limit.])
/// #show-parameter-block("minor-tick-limit", "int", default: 1000, [Upper minor tick limit.])
/// #show-parameter-block("auto-tick-factors", "array", [List of tick factors used for automatic tick step determination.])
/// #show-parameter-block("auto-tick-count", "int", [Number of ticks to generate by default.])
///
/// #show-parameter-block("stroke", "stroke", [Axis stroke style.])
/// #show-parameter-block("label.offset", "number", [Distance to move axis labels away from the axis.])
/// #show-parameter-block("label.anchor", "anchor", [Anchor of the axis label to use for it's placement.])
/// #show-parameter-block("label.angle", "angle", [Angle of the axis label.])
/// #show-parameter-block("axis-layer", "float", [Layer to draw axes on (see @@on-layer() )])
/// #show-parameter-block("grid-layer", "float", [Layer to draw the grid on (see @@on-layer() )])
/// #show-parameter-block("background-layer", "float", [Layer to draw the background on (see @@on-layer() )])
/// #show-parameter-block("padding", "number", [Extra distance between axes and plotting area. For schoolbook axes, this is the length of how much axes grow out of the plotting area.])
/// #show-parameter-block("tick.stroke", "stroke", [Major tick stroke style.])
/// #show-parameter-block("tick.minor-stroke", "stroke", [Minor tick stroke style.])
/// #show-parameter-block("tick.offset", ("number", "ratio"), [Major tick offset along the tick's direction, can be relative to the length.])
/// #show-parameter-block("tick.minor-offset", ("number", "ratio"), [Minor tick offset along the tick's direction, can be relative to the length.])
/// #show-parameter-block("tick.length", ("number"), [Major tick length.])
/// #show-parameter-block("tick.minor-length", ("number", "ratio"), [Minor tick length, can be relative to the major tick length.])
/// #show-parameter-block("tick.label.offset", ("number"), [Major tick label offset away from the tick.])
/// #show-parameter-block("tick.label.angle", ("angle"), [Major tick label angle.])
/// #show-parameter-block("tick.label.anchor", ("anchor"), [Anchor of major tick labels used for positioning.])
/// #show-parameter-block("tick.label.show", ("auto", "bool"), default: auto, [Set visibility of tick labels. A value of `auto` shows tick labels for all but mirrored axes.])
/// #show-parameter-block("grid.stroke", "stroke", [Major grid line stroke style.])
/// #show-parameter-block("grid.minor-stroke", "stroke", [Minor grid line stroke style.])
/// #show-parameter-block("break-point.width", "number", [Axis break width along the axis.])
/// #show-parameter-block("break-point.length", "number", [Axis break length.])
///
/// #show-parameter-block("shared-zero", ("bool", "content"), default: "$0$", [School-book style axes only: Content to display at the plots origin (0,0). If set to `false`, nothing is shown. Having this set, suppresses auto-generated ticks for $0$!])
#let default-style = (
  mark: none,
  stroke: (paint: black, cap: "square"),
  fill: none,

  padding: (0cm, 0cm),

  show-zero: true,
  zero-label: $0$,

  axis-layer: 0,
  tick-layer: 0,
  grid-layer: 0,

  tick: (
    stroke: black + 1pt,
    minor-stroke: black + .5pt,

    offset: 0cm,
    length: .2cm,
    minor-offset: 0cm,
    minor-length: .1cm,
    flip: false,

    label: (
      "show": auto,
      offset: .1cm,
      angle: 0deg,
      anchor: "center",
      draw: (pos, body, angle, anchor) => {
        draw.content(pos, body, angle: angle, anchor: anchor)
      },
    ),
  ),

  grid: (
    stroke: black + .5pt,
    minor-stroke: black + .25pt,
  ),

  // Overrides
  x: (
    tick: (
      label: (
        anchor: "north",
      ),
    ),
  ),
  y: (
    tick: (
      flip: true,
      label: (
        anchor: "east",
      ),
    ),
  ),
  x2: (
    tick: (
      flip: true,
      label: (
        anchor: "south",
      ),
    ),
  ),
  y2: (
    tick: (
      label: (
        anchor: "west",
      ),
    ),
  ),
  distal: (
    tick: (
      flip: true,
      label: (
        anchor: "east",
      )
    )
  ),
)

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

#let _prepare-style(ptx, style) = {
  let ctx = ptx.cetz-ctx
  let resolve-number = cetz.util.resolve-number.with(ctx)
  let relative-to(val, to) = {
    return if type(val) == ratio {
      val * to
    } else {
      val
    }
  }
  let resolve-relative-number(val, to) = {
    return resolve-number(relative-to(val, to))
  }

  if type(style.padding) != array {
    style.padding = (style.padding,) * 2
  }
  style.padding = style.padding.map(resolve-number)

  style.tick.offset = resolve-number(style.tick.offset)
  style.tick.length = resolve-number(style.tick.length)
  style.tick.minor-offset = resolve-relative-number(style.tick.minor-offset, style.tick.offset)
  style.tick.minor-length = resolve-relative-number(style.tick.minor-length, style.tick.length)

  style.tick.label.offset = resolve-number(style.tick.label.offset)

  return style
}

#let _get-axis-style(ptx, style, name) = {
  return _prepare-style(ptx, if name in style {
    cetz.util.merge-dictionary(style, style.at(name))
  } else {
    style
  })
}


///
#let cartesian-scientific(projections: none, name: none, style: (:)) = {
  return (
    name: name,
    draw: (ptx) => {
      let proj = projections.at(0)
      let axes = proj.axes
      let x = axes.at(0)
      let y = axes.at(1)

      let style = _prepare-style(ptx, cetz.styles.resolve(ptx.cetz-ctx.style,
        root: "axes", merge: style, base: default-style))
      let x-style = _get-axis-style(ptx, style, "x")
      let y-style = _get-axis-style(ptx, style, "y")
      let x2-style = _get-axis-style(ptx, style, "x2")
      let y2-style = _get-axis-style(ptx, style, "y2")

      let (south-west, south-east, north-west, north-east) = (proj.transform)(
        (x.min, y.min), (x.max, y.min),
        (x.min, y.max), (x.max, y.max),
      )

      let x-padding = x-style.padding
      let y-padding = y-style.padding

      let x-low = vector.add(south-west, (-x-padding.at(0), -y-padding.at(0)))
      let x-high = vector.add(south-east, (+x-padding.at(1), -y-padding.at(0)))
      let y-low = vector.add(south-west, (-x-padding.at(0), -y-padding.at(0)))
      let y-high = vector.add(north-west, (-x-padding.at(0), y-padding.at(1)))

      let x2-low = vector.add(north-west, (-x-padding.at(0), y-padding.at(1)))
      let x2-high = vector.add(north-east, (+x-padding.at(1), y-padding.at(1)))
      let y2-low = vector.add(south-east, (x-padding.at(1), -y-padding.at(0)))
      let y2-high = vector.add(north-east, (x-padding.at(1), y-padding.at(1)))

      let axes = (
        (x, 0, south-west, south-east, x-low, x-high, x-style, false),
        (y, 1, south-west, north-west, y-low, y-high, y-style, false),
        (x, 0, north-west, north-east, x2-low, x2-high, x2-style, true),
        (y, 1, south-east, north-east, y2-low, y2-high, y2-style, true),
      )

      for (ax, component, low, high, frame-low, frame-high, style, mirror) in axes {
        draw.on-layer(style.axis-layer, {
          draw.line(frame-low, frame-high, stroke: style.stroke, mark: style.mark)
        })
        if "computed-ticks" in ax {
          let low = low.enumerate().map(((i, v)) => {
            if i == component { v } else { frame-low.at(i) }
          })
          let high = high.enumerate().map(((i, v)) => {
            if i == component { v } else { frame-low.at(i) }
          })

          if not mirror {
            ticks.draw-cartesian-grid(low, high, component, ax, ax.computed-ticks, (0,0), (1,0), style)
          }
          ticks.draw-cartesian(low, high, ax.computed-ticks, style, is-mirror: mirror)
        }
      }
    },
  )
}

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

      let style = _prepare-style(ptx, cetz.styles.resolve(ptx.cetz-ctx.style,
        root: "axes", merge: style.named(), base: default-style-schoolbook))
      let x-style = _get-axis-style(ptx, style, "x")
      let y-style = _get-axis-style(ptx, style, "y")

      let (zero, min-x, max-x, min-y, max-y) = (proj.transform)(
        zero,
        vector.add(zero, (x.min, 0)), vector.add(zero, (x.max, 0)),
        vector.add(zero, (0, y.min)), vector.add(zero, (0, y.max)),
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
        ticks.draw-cartesian-grid(min-x, max-x, 0, x, x.computed-ticks, min-y, max-y, x-style)
        ticks.draw-cartesian(min-x, max-x, x.computed-ticks, x-style)
      }

      draw.on-layer(y-style.axis-layer, {
        draw.line((rel: outset-min-y, to: min-y),
                  (rel: outset-max-y, to: max-y),
          mark: y-style.mark,
          stroke: y-style.stroke)
      })
      if "computed-ticks" in y {
        ticks.draw-cartesian-grid(min-y, max-y, 1, y, y.computed-ticks, min-x, max-x, y-style)
        ticks.draw-cartesian(min-y, max-y, y.computed-ticks, y-style)
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

      let style = _prepare-style(ptx, cetz.styles.resolve(ptx.cetz-ctx.style,
        root: "axes", merge: style.named(), base: default-style))
      let angular-style = _get-axis-style(ptx, style, "angular")
      let distal-style = _get-axis-style(ptx, style, "distal")

      let r-padding = angular-style.padding.first()
      let r-start = origin
      let r-end = vector.add(origin, (0, radius))
      draw.line(r-start, (rel: (0, radius + r-padding)), stroke: distal-style.stroke)
      if "computed-ticks" in distal {
        // TODO
        ticks.draw-distal-grid(proj, distal.computed-ticks, distal-style)
        ticks.draw-cartesian(r-start, r-end, distal.computed-ticks, distal-style)
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
