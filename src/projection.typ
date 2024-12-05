#import "/src/cetz.typ": vector

/// Create a new cartesian projection
///
/// - low (vector): Lower viewport corner
/// - high (vector): Upper viewport corner
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

/// Create a new polar projection
///
/// - low (vector): Lower viewport corner
/// - high (vector): Upper viewport corner
/// - start (angle): Start angle (0deg for full circle)
/// - stop (angle): Stop angle (360deg for full circle)
/// - axes (list): Axis array (angular, distal)
/// -> function Transformation for one or more vectors
#let polar(low, high, (angular, distal, ..), start: 0deg, stop: 360deg) = {
  let center = vector.lerp(low, high, .5)
  let radius = calc.min(..vector.sub(high, low).slice(0, 2)) / 2

  return (
    axes: (angular, distal),
    transform: (..v) => {
      return v.pos().map(v => {
        let theta = (angular.transform)(angular, v.at(0), start, stop)
        let r = (distal.transform)(distal, v.at(1), 0, radius)

        vector.add(center, (calc.cos(theta) * r, calc.sin(theta) * r, 0))
      })
    },
  )
}
