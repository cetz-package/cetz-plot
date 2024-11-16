#import "/src/cetz.typ"
#import cetz: util, vector, draw

#import "/src/plot/formats.typ"

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

// Compute list of linear ticks for axis
//
// - axis (axis): Axis
#let compute-linear-ticks(axis, add-zero: true) = {
  let (min, max) = (axis.min, axis.max)
  let dt = max - min; if (dt == 0) { dt = 1 }
  let ticks = axis.ticks
  let ferr = util.float-epsilon
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

      let n = range(int(min * s), int(max * s + 1.5))
      for t in n {
        let v = (t / s - min) / dt
        if t / s == 0 and not add-zero { continue }

        if v >= 0 - ferr and v <= 1 + ferr {
          l.push((v, format-tick-value(t / s, ticks), true))
          major-tick-values.push(v)
        }
      }
    }

    if "minor-step" in ticks and ticks.minor-step != none {
      assert(ticks.minor-step >= 0,
             message: "Axis minor tick step must be positive")
      if axis.min > axis.max { ticks.minor-step *= -1 }

      let s = 1 / ticks.minor-step

      let num-ticks = int(max * s + 1.5) - int(min * s)
      assert(num-ticks <= minor-tick-limit,
             message: "Number of minor ticks exceeds limit " + str(minor-tick-limit))

      let n = range(int(min * s), int(max * s + 1.5))
      for t in n {
        let v = (t / s - min) / dt
        if v in major-tick-values {
          // Prefer major ticks over minor ticks
          continue
        }

        if v != none and v >= 0 and v <= 1 + ferr {
          l.push((v, none, false))
        }
      }
    }

  }

  return l
}

// Compute list of linear ticks for axis
//
// - axis (axis): Axis
#let compute-logarithmic-ticks(axis, add-zero: true) = {
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

      let n = range(
        int(min * s),
        int(max * s + 1.5)
      )

      for t in n {
        let v = (t / s - min) / dt
        if t / s == 0 and not add-zero { continue }

        if v >= 0 - ferr and v <= 1 + ferr {
          l.push((v, format-tick-value( calc.pow(axis.base, t / s), ticks), true))
          major-tick-values.push(v)
        }
      }
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

    v = value-on-axis(axis, v)
    if v != none and v >= 0 and v <= 1 {
      l.push((v, label, true))
    }
  })
}

// Compute list of axis ticks
//
// A tick triple has the format:
//   (rel-value: float, label: content, major: bool)
//
// - mode (str): "lin" or "log"
// - axis (axis): Axis object
#let compute-ticks(mode, axis, add-zero: true) = {
  let auto-tick-count = 11
  let auto-tick-factors = (1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10)

  let find-max-n-ticks(axis, n: 11) = {
    let dt = calc.abs(axis.max - axis.min)
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
    compute-logarithmic-ticks(axis, add-zero: add-zero)
  } else {
    compute-linear-ticks(axis, add-zero: add-zero)
  }
  ticks += fixed-ticks(axis)
  return ticks
}

// Place a list of tick marks and labels along a line
#let draw-cartesian(start, stop, ticks, style, is-mirror: false, show-zero: true) = {
  let draw-label = style.tick.label.draw

  draw.on-layer(style.tick-layer, {
    let dir = vector.norm(vector.sub(stop, start))
    let norm = (-dir.at(1), dir.at(0), dir.at(2, default: 0))

    let def(v, d) = {
      return if v == none or v == auto {d} else {v}
    }

    let show-label = style.tick.label.show
    if show-label == auto {
      show-label = not is-mirror
    }

    for (distance, label, is-major) in ticks {
      let offset = if is-major { style.tick.offset } else { style.tick.minor-offset }
      let length = if is-major { style.tick.length } else { style.tick.minor-length }
      let stroke = if is-major { style.tick.stroke } else { style.tick.minor-stroke }

      let pt = vector.lerp(start, stop, distance)
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
// - ptx (context): Plot context
// - start (vector): Axis start
// - stop (vector): Axis stop
// - component (int): Vector compontent to use as direction
// - axis (dictionary): The axis
// - ticks (array): The computed ticks
// - low (vector): Start position of a grid-line at tick 0
// - high (vector): End position of a grid-line at tick 0
// - style (style): Style
#let draw-cartesian-grid(start, stop, component, axis, ticks, low, high, style) = {
  let kind = if axis.grid in (true, "major") {
    1
  } else if axis.grid == "minor" {
    2
  } else if axis.grid == "both" {
    3
  } else {
    0
  }

  if kind > 0 {
    draw.on-layer(style.grid-layer, {
      for (distance, label, is-major) in ticks {
        let offset = vector.lerp(start, stop, distance)

        let start = low
        start.at(component) = offset.at(component)
        let end = high
        end.at(component) = offset.at(component)

        // Draw a minor line
        if not is-major and kind >= 2 {
          draw.line(start, end, stroke: style.grid.minor-stroke)
        }
        // Draw a major line
        if is-major and (kind == 1 or kind == 3) {
          draw.line(start, end, stroke: style.grid.stroke)
        }
      }
    })
  }
}
