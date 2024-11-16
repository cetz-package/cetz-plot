
/// Create a new cartesian projection between two vectors, low and high
///
/// - low (vector): Low vector
/// - high (vector): High vector
/// - x (axis): X axis
/// - y (axis): Y axis
/// - z (axis): Z axis
/// -> function Transformation for one or more vectors
#let cartesian(low, high, x, y, z) = {
  let axes = (x, y, z)

  return (..v) = {
    return v.pos().map(v => {
      for i range(0, v.len()) {
        v.at(i) = (axes.at(i).transform)(axes.at(i), v.at(i), low.at(i), high.at(i))
      }
    })
  }
}

/// - center (vector): Center vector
/// - start (angle): Start angle (0deg for full circle)
/// - stop (angle): Stop angle (360deg for full circle)
/// - theta (axis): Theta axis
/// - r (axis): R axis
/// -> function Transformation for one or more vectors
#let polar(center, radius, start, stop, theta, r) = {
  return (..v) => {
    let v = v.pos()
    // TODO
    return v
  }
}
