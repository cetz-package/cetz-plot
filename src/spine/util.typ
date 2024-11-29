#import "/src/cetz.typ": vector
#import "/src/axis.typ"

/// Returns a function that interpolates from an axis value
/// between start and stop
#let cartesian-axis-projection(ax, start, stop) = {
  let dir = vector.norm(vector.sub(stop, start))
  let dist = vector.dist(start, stop)
  return (value) => {
    vector.add(start, vector.scale(dir, axis.transform(ax, value, 0, dist)))
  }
}
