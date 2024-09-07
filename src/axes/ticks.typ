#import "/src/cetz.typ": vector, util, draw
#import "format.typ" as formats

// Format a tick value
#let format-tick-value(value, tic-options) = {
  // Without it we get negative zero in conversion
  // to content! Typst has negative zero floats.
  if value == 0 { value = 0 }

  let round(value, digits) = {
    calc.round(value, digits: digits)
  }

  let format-float(value, digits) = {
    $#round(value, digits)$
  }

  if type(value) != content {
    let format = tic-options.at("format", default: "float")
    if format == none {
      value = []
    } else if type(format) == content {
      value = format
    } else if type(format) == function {
      value = (format)(value)
    } else if format == "sci" {
      value = formats.sci(value, digits: tic-options.at("decimals", default: 2))
    } else {
      value = format-float(value, tic-options.at("decimals", default: 2))
    }
  } else if type(value) != content {
    value = str(value)
  }

  if tic-options.at("unit", default: none) != none {
    value += tic-options.unit
  }
  return value
}

// Get value on axis [0, 1]
//
// - axis (axis): Axis
// - v (number): Value
// -> float
#let value-on-axis(axis, v) = {
  if v == none { return }
  let (min, max) = (axis.min, axis.max)
  let dt = max - min; if dt == 0 { dt = 1 }

  return (v - min) / dt
}

// Compute list of linear ticks for axis
//
// - axis (axis): Axis
#let compute-linear-ticks(axis, style, add-zero: true) = {
  let (min, max) = (axis.min, axis.max)
  let dt = max - min; if (dt == 0) { dt = 1 }
  let ticks = axis.ticks
  let ferr = util.float-epsilon
  let tick-limit = style.tick-limit
  let minor-tick-limit = style.minor-tick-limit

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
#let compute-logarithmic-ticks(axis, style, add-zero: true) = {
  let ferr = util.float-epsilon
  let (min, max) = (
    calc.log(calc.max(axis.min, ferr), base: axis.base), 
    calc.log(calc.max(axis.max, ferr), base: axis.base)
  )
  let dt = max - min; if (dt == 0) { dt = 1 }
  let ticks = axis.ticks

  let tick-limit = style.tick-limit
  let minor-tick-limit = style.minor-tick-limit
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
#let fixed-ticks(axis) = {
  let l = ()
  if "list" in axis.ticks {
    for t in axis.ticks.list {
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
    }
  }
  return l
}

// Compute list of axis ticks
//
// A tick triple has the format:
//   (rel-value: float, label: content, major: bool)
//
// - axis (axis): Axis object
#let compute-ticks(axis, style, add-zero: true) = {
  let find-max-n-ticks(axis, n: 11) = {
    let dt = calc.abs(axis.max - axis.min)
    let scale = calc.floor(calc.log(dt, base: 10) - 1)
    if scale > 5 or scale < -5 {return none}

    let (step, best) = (none, 0)
    for s in style.auto-tick-factors {
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
    axis.ticks.step = find-max-n-ticks(axis, n: style.auto-tick-count)
  }
  if axis.ticks.minor-step == auto {
    axis.ticks.minor-step = if axis.ticks.step != none {
      axis.ticks.step / 5
    } else {
      none
    }
  }

  let ticks = if axis.mode == "log" {
    compute-logarithmic-ticks(axis, style, add-zero: add-zero)
  } else {
    compute-linear-ticks(axis, style, add-zero: add-zero)
  }
  ticks += fixed-ticks(axis)
  return ticks
}

// Place a list of tick marks and labels along a path
#let place-ticks-on-line(ticks, start, stop, style, flip: false, is-mirror: false) = {
  let dir = vector.sub(stop, start)
  let norm = vector.norm((-dir.at(1), dir.at(0), dir.at(2, default: 0)))

  let def(v, d) = {
    return if v == none or v == auto {d} else {v}
  }

  let show-label = style.tick.label.show
  if show-label == auto {
    show-label = not is-mirror
  }

  for (distance, label, is-major) in ticks {
    let offset = style.tick.offset
    let length = if is-major { style.tick.length } else { style.tick.minor-length }
    if flip {
      offset *= -1
      length *= -1
    }

    let pt = vector.lerp(start, stop, distance)
    let a = vector.add(pt, vector.scale(norm, offset))
    let b = vector.add(a, vector.scale(norm, length))

    draw.line(a, b, stroke: style.tick.stroke)

    if show-label and label != none {
      let offset = style.tick.label.offset
      if flip {
        offset *= -1
        length *= -1
      }

      let c = vector.sub(if length <= 0 { b } else { a },
        vector.scale(norm, offset))

      let angle = def(style.tick.label.angle, 0deg)
      let anchor = def(style.tick.label.anchor, "center")

      draw.content(c, [#label], angle: angle, anchor: anchor)
    }
  }
}