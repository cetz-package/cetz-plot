#import "/src/cetz.typ"
#import cetz: util, vector, draw

#import "/src/plot/formats.typ"

#let _get-grid-mode(mode) = {
  return if mode in (true, "major") {
    1
  } else if mode == "minor" {
    2
  } else if mode == "both" {
    3
  } else {
    0
  }
}

#let _draw-grid(mode, is-major) = {
  return mode >= 3 or (is-major and mode == 1) or mode == 2
}

// Format a tick value
#let format-tick-value(value, tic-options) = {
  // Without it we get negative zero in conversion
  // to content! Typst has negative zero floats.
  if value == 0 { value = 0 }

  if type(value) != std.content {
    let format = tic-options.at("format", default: "float")
    if format == none {
      value = []
    } else if type(format) == std.content {
      value = format
    } else if type(format) == function {
      value = (format)(value)
    } else if format == "sci" {
      value = formats.sci(value, digits: tic-options.at("decimals", default: 2))
    } else {
      value = formats.decimal(value, digits: tic-options.at("decimals", default: 2))
    }
  } else if type(value) != std.content {
    value = str(value)
  }

  return value
}

#let clip-ticks(axis, ticks) = {
  let (min, max) = (axis.min, axis.max)
  let err = util.float-epsilon
  /*
  return ticks.filter(((value, ..)) => {
    min - err <= value and value <= max + err
  })
  */
  return ticks
}

/// Compute list of linear ticks
///
/// - ax (axis): Axes
/// -> List of ticks
#let compute-linear-ticks(ax) = {
  let compute-list(min, max, step, limit) = {
    if step == none or step <= 0 or min == none or max == none {
      return ()
    }

    let num-negative = int((0 - min) / step)
    let num-positive = int((max - 0) / step)

    return range(-num-negative, num-positive + 1).map(t => {
      t * step
    })
  }

  let major-limit = ax.at("tick-limit", default: 100)
  let minor-limit = ax.at("minor-tick-limit", default: 1000)

  let major = compute-list(ax.min, ax.max, ax.ticks.step, major-limit)
  let minor = compute-list(ax.min, ax.max, ax.ticks.minor-step, minor-limit)

  minor.map(value => {
    (value, none, false)
  }) + major.map(value => {
    (value, format-tick-value(value, ax.ticks), true)
  })
}

/// Compute list of logarithmic ticks
///
/// - ax (axis): Axis
/// -> List of ticks
#let compute-logarithmic-ticks(ax) = {
  let min = calc.log(calc.max(axis.min, util.float-epsilon), base: ax.base)
  let max = calc.log(calc.max(axis.max, util.float-epsilon), base: ax.base)

  let compute-list(min, max, step, limit) = {
    let num-positive = int((max - 0) / step)

    // TODO

    return ()
  }

  let major-limit = ax.at("tick-limit", default: 100)
  let minor-limit = ax.at("minor-tick-limit", default: 1000)

  let major = compute-list(ax.min, ax.max, ax.ticks.step, major-limit)
  let minor = compute-list(ax.min, ax.max, ax.ticks.minor-step, minor-limit)

  minor.map(value => {
    (value, none, false)
  }) + major.map(value => {
    (value, format-tick-value(value, ax.ticks), true)
  })
}

// Compute list of linear ticks for axis
//
// - axis (axis): Axis
#let compute-logarithmic-ticks__(axis, add-zero: true) = {
  let ferr = util.float-epsilon
  let (min, max) = (
    calc.log(calc.max(axis.min, ferr), base: axis.base),
    calc.log(calc.max(axis.max, ferr), base: axis.base)
  )
  let dt = max - min; if (dt == 0) { dt = 1 }
  let ticks = axis.ticks

  let tick-limit = axis.at("tick-limit", default: 100)
  let minor-tick-limit = axis.at("minor-tick-limit", default: 1000)
  let l = ()

  if ticks != none {
    let major-tick-values = ()
    if "step" in ticks and ticks.step != none {
      assert(ticks.step >= 0,
             message: "Axis tick step must be positive and non 0.")
      if axis.min > axis.max { ticks.step *= -1 }

      let s = 1 / ticks.step

      let num-ticks = int(max * s + 1.5)  - int(min * s)
      assert(num-ticks <= tick-limit,
             message: "Number of major ticks exceeds limit " + str(tick-limit))

    }

    if "minor-step" in ticks and ticks.minor-step != none {
      assert(ticks.minor-step >= 0,
             message: "Axis minor tick step must be positive")
      if axis.min > axis.max { ticks.minor-step *= -1 }

      let s = 1 / ticks.step
      let n = range(int(min * s)-1, int(max * s + 1.5)+1)

      for t in n {
        for vv in range(1, int(axis.base / ticks.minor-step)) {

          let v = ( (calc.log(vv * ticks.minor-step, base: axis.base) + t)/ s - min) / dt
          if v in major-tick-values {continue}

          if v != none and v >= 0 and v <= 1 + ferr {
            l.push((v, none, false))
          }

        }

      }
    }
  }

  return l
}

// Get list of fixed axis ticks
//
// - axis (axis): Axis object
#let fixed-ticks(ax) = {
  let list = ax.at("list", default: none)
  if type(list) == function {
    list = (list)(ax)
  }
  if type(list) != array {
    return ()
  }

  return list.map(t => {
    let (v, label) = (none, none)
    if type(t) in (float, int) {
      v = t
      label = format-tick-value(t, axis.ticks)
    } else {
      (v, label) = t
    }

    if v != none {
      return (v, label, true)
    }
  }).filter(v => v != none)
}

// Compute list of axis ticks
//
// A tick triple has the format:
//   (rel-value: float, label: content, major: bool)
//
// - mode (str): "lin" or "log"
// - axis (axis): Axis object
#let compute-ticks(mode, axis) = {
  let auto-tick-count = 11
  let auto-tick-factors = (1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10)

  let find-max-n-ticks(ax, n: 11) = {
    if ax.min == none or ax.max == none {
       return none
    }

    let dt = calc.abs(ax.max - ax.min)
    let scale = calc.floor(calc.log(dt, base: 10) - 1)
    if scale > 5 or scale < -5 {return none}

    let (step, best) = (none, 0)
    for s in auto-tick-factors {
      s = s * calc.pow(10, scale)

      let divs = calc.abs(dt / s)
      if divs >= best and divs <= n {
        step = s
        best = divs
      }
    }
    return step
  }

  if axis == none or axis.ticks == none { return () }
  if axis.ticks.step == auto {
    axis.ticks.step = find-max-n-ticks(axis, n: auto-tick-count)
  }
  if axis.ticks.minor-step == auto {
    axis.ticks.minor-step = if axis.ticks.step != none {
      axis.ticks.step / 5
    } else {
      none
    }
  }

  let ticks = if mode == "log" {
    compute-logarithmic-ticks(axis)
  } else {
    compute-linear-ticks(axis)
  }
  ticks += fixed-ticks(axis)
  return ticks
}

// Place a list of tick marks and labels along a line
#let draw-cartesian(transform, norm, ticks, style, is-mirror: false, show-zero: true) = {
  let draw-label = style.tick.label.draw

  draw.on-layer(style.tick-layer, {
    let def(v, d) = {
      return if v == none or v == auto {d} else {v}
    }

    let show-label = style.tick.label.show
    if show-label == auto {
      show-label = not is-mirror
    }

    for (value, label, is-major) in ticks {
      let offset = if is-major { style.tick.offset } else { style.tick.minor-offset }
      let length = if is-major { style.tick.length } else { style.tick.minor-length }
      let stroke = if is-major { style.tick.stroke } else { style.tick.minor-stroke }

      let pt = transform(value)
      if style.tick.flip {
        offset = -offset - length
      }

      let a = vector.add(pt, vector.scale(norm, offset))
      let b = vector.add(a, vector.scale(norm, length))

      draw.line(a, b, stroke: stroke)

      if draw-label != none and show-label and label != none {
        let offset = style.tick.label.offset
        if style.tick.flip {
          offset = -offset - length
        }

        let angle = def(style.tick.label.angle, 0deg)
        let anchor = def(style.tick.label.anchor, "center")
        let pos = vector.sub(a, vector.scale(norm, offset))

        draw-label(pos, label, angle, anchor)
      }
    }
  })
}

// Draw grid lines for the ticks of an axis
//
#let draw-cartesian-grid(proj, offset, axis, ticks, style) = {
  let kind = _get-grid-mode(axis.grid)
  if kind > 0 {
    draw.on-layer(style.grid-layer, {
      for (value, _, major) in ticks {
        let start = proj(value)
        let end = vector.add(start, offset)

        // Draw a minor line
        if not major and kind >= 2 {
          draw.line(start, end, stroke: style.grid.minor-stroke)
        }
        // Draw a major line
        if major and (kind == 1 or kind == 3) {
          draw.line(start, end, stroke: style.grid.stroke)
        }
      }
    })
  }
}

/// Draw angular polar grid
#let draw-angular-grid(projection, ticks, style) = {
  let (angular, distal, ..) = projection.axes
  let mode = _get-grid-mode(distal.grid)
  if mode == 0 {
    return
  }

  let (origin,) = (projection.transform)(
    (angular.min, distal.min),
  )

  let padding = style.padding.first()
  let range = angular.max - angular.min

  draw.on-layer(style.grid-layer, {
    for (pos, _, is-major) in ticks {
      if not _draw-grid(mode, is-major) {
        continue
      }

      let (pos,) = (projection.transform)(
        (angular.min + pos * range, distal.max),
      )

      pos = vector.add(pos, vector.scale(vector.norm(vector.sub(pos, origin)), padding))

      draw.line(origin, pos,
        stroke: if is-major { style.grid.stroke } else { style.grid.minor-stroke })
    }
  })
}

/// Draw distal polar grid
#let draw-distal-grid(projection, ticks, style) = {
  let (angular, distal, ..) = projection.axes
  let mode = _get-grid-mode(distal.grid)
  if mode == 0 {
    return
  }

  let (origin, start, stop) = (projection.transform)(
    (angular.min, distal.min),
    (angular.min, distal.max),
    (angular.max, distal.max),
  ).map(v => v.map(calc.round.with(digits: 6)))

  let is-arc = start != stop
  let radius = vector.dist(origin, start)
  let range = distal.max - distal.min

  let draw-ring = (position, stroke) => {
    let v = distal.min + position * range
    if distal.min < v and v < distal.max {
      if not is-arc {
        draw.circle(origin, radius: radius / range * v,
          stroke: stroke,
          fill: none)
      } else {
        let (start, mid, stop) = (projection.transform)(
          (angular.min, v),
          ((angular.min + angular.max) / 2, v),
          (angular.max, v)
        )

        draw.arc-through(start, mid, stop,
          stroke: stroke,
          fill: none)
      }
    }
  }

  draw.on-layer(style.grid-layer, {
    for (pos, _, is-major) in ticks {
      if not _draw-grid(mode, is-major) {
        continue
      }

      draw-ring(pos, if is-major { style.grid.stroke } else { style.grid.minor-stroke })
    }
  })
}
