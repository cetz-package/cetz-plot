#import "/src/cetz.typ"
#import cetz.util: bezier

/// Clip line-strip in rect
///
/// - points (array): Array of vectors representing a line-strip
/// - low (vector): Lower clip-window coordinate
/// - high (vector): Upper clip-window coordinate
/// - fill (bool): Return fillable shapes
/// - generate-edge-points (bool): Generate interpolated points on clipped edges
/// -> array List of line-strips representing the paths insides the clip-window
#let clipped-paths-rect(points, low, high, fill: false, generate-edge-points: false) = {
  let (min-x, max-x) = (calc.min(low.at(0), high.at(0)),
                        calc.max(low.at(0), high.at(0)))
  let (min-y, max-y) = (calc.min(low.at(1), high.at(1)),
                        calc.max(low.at(1), high.at(1)))

  let in-rect((x, y)) = {
    return (x >= min-x and x <= max-x and
            y >= min-y and y <= max-y)
  }

  let edges = (
    ((min-x, min-y), (min-x, max-y)),
    ((max-x, min-y), (max-x, max-y)),
    ((min-x, min-y), (max-x, min-y)),
    ((min-x, max-y), (max-x, max-y)),
  )

  let interpolated-end(a, b) = {
    let pts = ()
    for (edge-a, edge-b) in edges {
      let pt = cetz.intersection.line-line(a, b, edge-a, edge-b)
      if pt != none {
        pts.push(pt)
      }
    }
    return pts
  }

  // Find lines crossing the rect bounds
  // by storing all crossings as tuples (<index>, <goes-inside>, <point-on-border>)
  let crossings = ()

  // Push a pseudo entry for the last point, if it is insides the bounds.
  let was-inside = in-rect(points.at(0))
  if was-inside {
    crossings.push((0, true, points.first()))
  }

  // Find crossings and compute intersection points.
  for i in range(1, points.len()) {
    let current-inside = in-rect(points.at(i))
    if current-inside != was-inside {
      crossings.push((
        i,
        current-inside,
        interpolated-end(points.at(i - 1), points.at(i)).first()))
      was-inside = current-inside
    } else if not current-inside {
      let (px, py) = points.at(i - 1)
      let (cx, cy) = points.at(i)
      let (lo-x, hi-x) = (calc.min(px, cx), calc.max(px, cx))
      let (lo-y, hi-y) = (calc.min(py, cy), calc.max(py, cy))

      let x-differs = (lo-x < min-x and hi-x > max-x) or (lo-x < max-x and hi-x > max-x)
      let y-differs = (lo-y < min-y and hi-y > max-y) or (lo-y < max-y and hi-y > max-y)
      if x-differs or y-differs {
        for pt in interpolated-end(points.at(i - 1), points.at(i)) {
          crossings.push((i, not current-inside, pt))
          current-inside = not current-inside
        }
      }
    }
  }

  // Push a pseudo entry for the last point, if it is insides the bounds.
  if in-rect(points.last()) and crossings.last().at(1) {
    crossings.push((points.len() - 1, false, points.last()))
  }

  // Generate paths
  let paths = ()
  for i in range(1, crossings.len()) {
    let (a-index, a-dir, a-pt) = crossings.at(i - 1)
    let (b-index, b-dir, b-pt) = crossings.at(i)

    if a-dir {
      let path = ()

      // If we must generate edge points, take the previous crossing
      // as source point and interpolate between that and the current one.
      if generate-edge-points and i > 2 {
        let (c-index, c-dir, c-pt) = crossings.at(i - 2)

        let n = a-index - c-index
        if n > 1 {
          path += range(0, n).map(t => {
            cetz.vector.lerp(c-pt, a-pt, t / (n - 1))
          })
        }
      }

      // Append the path insides the bounds
      path.push(a-pt)
      path += points.slice(a-index, b-index)
      path.push(b-pt)

      // Insert the last end point to connect
      // to a filled area.
      if fill and paths.len() > 0 {
        path.insert(0, paths.last().last())
      }

      paths.push(path)
    }
  }

  return paths
}

/// Compute clipped stroke paths
///
/// - points (array): X/Y data points
/// - low (vector): Lower clip-window coordinate
/// - high (vector): Upper clip-window coordinate
/// -> array List of stroke paths
#let compute-stroke-paths = clipped-paths-rect.with(fill: false)
/// Compute clipped fill path
///
/// - points (array): X/Y data points
/// - low (vector): Lower clip-window coordinate
/// - high (vector): Upper clip-window coordinate
/// -> array List of fill paths
#let compute-fill-paths = clipped-paths-rect.with(fill: true)

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
