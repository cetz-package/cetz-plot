#import "/src/spine.typ"
#import "/src/projection.typ"
#import "/src/cetz.typ"

///
#let new(spine: spine.cartesian-scientific, projection: projection.cartesian, origin: (0, 0), size: auto, ..axes-style) = {
  let axes = axes-style.pos()
  let style = axes-style.named()

  assert(axes.len() > 0,
    message: "Axes must be set!")
  assert(calc.rem(axes.len(), 2) == 0,
    message: "Axes must be a multiple of two!")

  ((
    priority: 100,
    fn: ptx => {
      let (_, origin) = cetz.coordinate.resolve(ptx.cetz-ctx, origin)
      let size = size
      if size == auto {
        size = ptx.default-size
      }
      size = size.map(cetz.util.resolve-number.with(ptx.cetz-ctx)).map(calc.abs)
      size = cetz.vector.add(origin, size)

      let axes = axes.map(name => ptx.axes.at(name))
      let axis-pairs = axes.chunks(2, exact: true)
      let projections = axis-pairs.map(((x, y)) => {
        (projection)(origin, size, (x, y))
      })

      let spine = if spine != none {
        spine(
          projections: projections,
        )
      }

      ptx.plots.push((
        spine: spine,
        projections: projections,
      ))
      return ptx
    }
  ),)
}
