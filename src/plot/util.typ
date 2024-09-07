#import "/src/cetz.typ"
#import cetz.util: bezier

/// Return points of a sampled catmull-rom through the
/// input points.
///
/// - points (array): Array of input vectors
/// - tension (float): Catmull-Rom tension
/// - samples (int): Number of samples
/// -> array Array of vectors
#let sampled-spline-data(points, tension, samples) = {
  assert(samples >= 1 and samples <= 100,
    message: "Must at least use 1 sample per curve")
  
  let curves = bezier.catmull-to-cubic(points, tension)
  let pts = ()
  for c in curves {
    for t in range(0, samples + 1) {
      let t = t / samples
      pts.push(bezier.cubic-point(..c, t))
    }
  }
  return pts
}

/// Simplify linear data by "detecting" linear sections
/// and skipping points until the slope changes.
/// This can have a huge impact on the number of lines
/// getting rendered.
///
/// - data (array): Data points
/// - epsilon (float): Curvature threshold to treat data as linear
#let linearized-data(data, epsilon) = {
  let pts = ()
  // Current slope, set to none if infinite
  let dx = none
  // Previous point, last skipped point
  let prev = none
  let skipped = none
  // Current direction
  let dir = 0

  let len = data.len()
  for i in range(0, len) {
    let pt = data.at(i)
    if prev != none and i < len - 1 {
      let new-dir = pt.at(0) - prev.at(0)
      if new-dir == 0 {
        // Infinite slope
        if dx != none {
          if skipped != none {pts.push(skipped); skipped = none}
          pts.push(pt)
        } else {
          skipped = pt
        }
        dx = none
      } else {
        // Push the previous and the current point
        // if slope or direction changed
        let new-dx = ((pt.at(1) - prev.at(1)) / new-dir)
        if dx == none or calc.abs(new-dx - dx) > epsilon or (new-dir * dir) < 0 {
          if skipped != none {pts.push(skipped); skipped = none}
          pts.push(pt)

          dx = new-dx
          dir = new-dir
        } else {
          skipped = pt
        }
      }
    } else {
      if skipped != none {pts.push(skipped); skipped = none}
      pts.push(pt)
    }

    prev = pt
  }

  return pts
}

// Get the default axis orientation
// depending on the axis name
#let get-default-axis-horizontal(name) = {
  return lower(name).starts-with("x")
}

// Setup axes dictionary
//
// - axis-dict (dictionary): Existing axis dictionary
// - options (dictionary): Named arguments
// - plot-size (tuple): Plot width, height tuple
#let setup-axes(ctx, axis-dict, options, plot-size) = {
  import "/src/axes.typ"

  // Get axis option for name
  let get-axis-option(axis-name, name, default) = {
    let v = options.at(axis-name + "-" + name, default: default)
    if v == auto { default } else { v }
  }

  for (name, axis) in axis-dict {
    if not "ticks" in axis { axis.ticks = () }
    axis.label = get-axis-option(name, "label", $#name$)

    // Configure axis bounds
    axis.min = get-axis-option(name, "min", axis.min)
    axis.max = get-axis-option(name, "max", axis.max)

    assert(axis.min not in (none, auto) and
           axis.max not in (none, auto),
      message: "Axis min and max must be set.")
    if axis.min == axis.max {
      axis.min -= 1; axis.max += 1
    }

    axis.mode = get-axis-option(name, "mode", "lin")
    axis.base = get-axis-option(name, "base", 10)

    // Configure axis orientation
    axis.horizontal = get-axis-option(name, "horizontal",
      get-default-axis-horizontal(name))

    // Configure ticks
    axis.ticks.list = get-axis-option(name, "ticks", ())
    axis.ticks.step = get-axis-option(name, "tick-step", axis.ticks.step)
    axis.ticks.minor-step = get-axis-option(name, "minor-tick-step", axis.ticks.minor-step)
    axis.ticks.decimals = get-axis-option(name, "decimals", 2)
    axis.ticks.unit = get-axis-option(name, "unit", [])
    axis.ticks.format = get-axis-option(name, "format", axis.ticks.format)

    // Axis break
    axis.show-break = get-axis-option(name, "break", false)
    axis.inset = get-axis-option(name, "inset", (0, 0))

    // Configure grid
    axis.ticks.grid = get-axis-option(name, "grid", false)

    axis-dict.at(name) = axis
  }

  // Set axis options round two, after setting
  // axis bounds
  for (name, axis) in axis-dict {
    let changed = false

    // Configure axis aspect ratio
    let equal-to = get-axis-option(name, "equal", none)
    if equal-to != none {
      assert.eq(type(equal-to), str,
        message: "Expected axis name.")
      assert(equal-to != name,
        message: "Axis can not be equal to itself.")

      let other = axis-dict.at(equal-to, default: none)
      assert(other != none,
        message: "Other axis must exist.")
      assert(other.horizontal != axis.horizontal,
        message: "Equal axes must have opposing orientation.")

      let (w, h) = plot-size
      let ratio = if other.horizontal {
        h / w
      } else {
        w / h
      }
      axis.min = other.min * ratio
      axis.max = other.max * ratio

      changed = true
    }

    if changed {
      axis-dict.at(name) = axis
    }
  }

  for (name, axis) in axis-dict {
    axis-dict.at(name) = axes.prepare-axis(ctx, axis, name)
  }

  return axis-dict
}