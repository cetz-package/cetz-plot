/// Clip line-strip in rect
///
/// - points (array): Array of vectors representing a line-strip
/// - low (vector): Lower clip-window coordinate
/// - high (vector): Upper clip-window coordinate
/// -> array List of line-strips representing the paths insides the clip-window
#let clipped-paths-rect(points, ctx, fill: false) = {
  let (low, high) = ctx.clip
  let (min-x, max-x) = (calc.min(low.at(0), high.at(0)),
                        calc.max(low.at(0), high.at(0)))
  let (min-y, max-y) = (calc.min(low.at(1), high.at(1)),
                        calc.max(low.at(1), high.at(1)))

  let in-rect(pt) = {
    return (pt.at(0) >= min-x and pt.at(0) <= max-x and
            pt.at(1) >= min-y and pt.at(1) <= max-y)
  }

  let interpolated-end(a, b) = {
    if in-rect(a) and in-rect(b) {
      return b
    }

    let (x1, y1, ..) = a
    let (x2, y2, ..) = b

    if x2 - x1 == 0 {
      return (x2, calc.min(max-y, calc.max(y2, min-y)))
    }

    if y2 - y1 == 0 {
      return (calc.min(max-x, calc.max(x2, min-x)), y2)
    }

    let m = (y2 - y1) / (x2 - x1)
    let n = y2 - m * x2

    let x = x2
    let y = y2

    y = calc.min(max-y, calc.max(y, min-y))
    x = (y - n) / m

    x = calc.min(max-x, calc.max(x, min-x))
    y = m * x + n

    return (x, y)
  }

  // Append path to paths and return paths
  //
  // If path starts or ends with a vector of another part, merge those
  // paths instead appending path as a new path.
  let append-path(paths, path) = {
    if path.len() <= 1 {
      return paths
    }

    let cmp(a, b) = {
      return a.map(calc.round.with(digits: 8)) == b.map(calc.round.with(digits: 8))
    }

    let added = false
    for i in range(0, paths.len()) {
      let p = paths.at(i)
      if cmp(p.first(), path.last()) {
        paths.at(i) = path + p
        added = true
      } else if cmp(p.first(), path.first()) {
        paths.at(i) = path.rev() + p
        added = true
      } else if cmp(p.last(), path.first()) {
        paths.at(i) = p + path
        added = true
      } else if cmp(p.last(), path.last()) {
        paths.at(i) = p + path.rev()
        added = true
      }
      if added { break }
    }

    if not added {
      paths.push(path)
    }
    return paths
  }

  let clamped-pt(pt) = {
    return (calc.max(min-x, calc.min(pt.at(0), max-x)),
            calc.max(min-y, calc.min(pt.at(1), max-y)))
  }

  let paths = ()

  let path = ()
  let prev = points.at(0)
  let was-inside = in-rect(prev)
  if was-inside {
    path.push(prev)
  } else if fill {
    path.push(clamped-pt(prev))
  }

  for i in range(1, points.len()) {
    let prev = points.at(i - 1)
    let pt = points.at(i)

    let is-inside = in-rect(pt)

    let (x1, y1) = prev
    let (x2, y2) = pt

    // Ignore lines if both ends are outsides the x-window and on the
    // same side.
    if (x1 < min-x and x2 < min-x) or (x1 > max-x and x2 > max-x) {
      if fill {
        let clamped = clamped-pt(pt)
        if path.last() != clamped {
          path.push(clamped)
        }
      }
      was-inside = false
      continue
    }

    if is-inside {
      if was-inside {
        path.push(pt)
      } else {
        path.push(interpolated-end(pt, prev))
        path.push(pt)
      }
    } else {
      if was-inside {
        path.push(interpolated-end(prev, pt))
      } else {
        let (a, b) = (interpolated-end(pt, prev),
                      interpolated-end(prev, pt))
        if in-rect(a) and in-rect(b) {
          path.push(a)
          path.push(b)
        } else if fill {
          let clamped = clamped-pt(pt)
          if path.last() != clamped {
            path.push(clamped)
          }
        }
      }

      if path.len() > 0 and not fill {
        paths = append-path(paths, path)
        path = ()
      }
    }
    
    was-inside = is-inside
  }

  // Append clamped last point if filling
  if fill and not in-rect(points.last()) {
    path.push(clamped-pt(points.last()))
  }

  if path.len() > 1 {
    paths = append-path(paths, path)
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