
/// Create a new cartesian projection between two vectors, low and high
///
/// - low (vector): Low vector
/// - high (vector): High vector
/// - axes (list): List of axes
/// -> function Transformation for one or more vectors
#let cartesian(low, high, axes) = {
  return (
    axes: axes,
    transform: (..v) => {
      return v.pos().map(v => {
        for i in range(0, v.len()) {
          if axes.at(i) != none {
            v.at(i) = (axes.at(i).transform)(axes.at(i), v.at(i), low.at(i), high.at(i))
          } else {
            v.at(i) = 0
          }
        }
        return v
      })
    },
  )
}

/// - center (vector): Center vector
/// - start (angle): Start angle (0deg for full circle)
/// - stop (angle): Stop angle (360deg for full circle)
/// - theta (axis): Theta axis
/// - r (axis): R axis
/// -> function Transformation for one or more vectors
#let polar(center, radius, start, stop, theta, r) = {
  return (
    axes: axes,
    transform: (..v) => {
      let v = v.pos()
      // TODO
      return v
    },
  )
}
