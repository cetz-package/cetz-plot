#import "/src/cetz.typ"

/// Clip line-strip in rect
///
/// - points (array): Array of vectors representing a line-strip
/// - low (vector): Lower clip-window coordinate
/// - high (vector): Upper clip-window coordinate
/// - fill (bool): Return fillable shapes
/// - generate-edge-points (bool): Generate interpolated points on clipped edges
/// -> array List of line-strips representing the paths insides the clip-window
#let clipped-paths-rect(points, ctx, fill: false, generate-edge-points: false) = {
  let (low, high) = ctx.clip
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
    for (edge-a, edge-b) in edges {
      let pt = cetz.intersection.line-line(a, b, edge-a, edge-b)
      if pt != none {
        return pt
      }
    }
  }


  // Find lines crossing the rect bounds
  // by storing all crossings as tuples (<index>, <goes-inside>, <point-on-border>)
  let crossings = ()

  // Push a pseudo entry for the last point, if it is insides the bounds.
  let was-inside = in-rect(points.at(0))
  if was-inside {
    crossings.push((0, true, points.first()))
  }

  // Find crossings and compute interseciton points.
  for i in range(1, points.len()) {
    let current-inside = in-rect(points.at(i))
    if current-inside != was-inside {
      crossings.push((
        i,
        current-inside,
        interpolated-end(points.at(i - 1), points.at(i))))
      was-inside = current-inside
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
