#import "/src/cetz.typ": draw, drawable, matrix, process, util

// Transform a single vector along a x, y and z axis
//
// - size (vector): Coordinate system size
// - x-axis (axis): X axis
// - y-axis (axis): Y axis
// - z-axis (axis): Z axis
// - vec (vector): Input vector to transform
// -> vector
#let transform-vec(size, x-axis, y-axis, z-axis, vec) = {
  let (ox, oy, ..) = (0, 0, 0)
  ox += x-axis.inset.at(0)
  oy += y-axis.inset.at(0)

  let (sx, sy) = size
  sx -= x-axis.inset.sum()
  sy -= y-axis.inset.sum()

  let x-range = x-axis.max - x-axis.min
  let y-range = y-axis.max - y-axis.min
  let z-range = 0 //z-axis.max - z-axis.min

  let fx = sx / x-range
  let fy = sy / y-range
  let fz = 0 //sz / z-range

  let x-low = calc.min(x-axis.min, x-axis.max)
  let x-high = calc.max(x-axis.min, x-axis.max)
  let y-low = calc.min(y-axis.min, y-axis.max)
  let y-high = calc.max(y-axis.min, y-axis.max)
  //let z-low = calc.min(z-axis.min, z-axis.max)
  //let z-hihg = calc.max(z-axis.min, z-axis.max)

  let (x, y, ..) = vec

  return (
    (x - x-axis.min) * fx + ox,
    (y - y-axis.min) * fy + oy,
    0) //(z - z-axis.min) * fz + oz)
}

// Draw inside viewport coordinates of two axes
//
// - size (vector): Axis canvas size (relative to origin)
// - x (axis): Horizontal axis
// - y (axis): Vertical axis
// - z (axis): Z axis
// - name (string,none): Group name
#let axis-viewport(size, x, y, z, body, name: none) = {
  draw.group(name: name, (ctx => {
    let transform = ctx.transform

    ctx.transform = matrix.ident()
    let (ctx, drawables, bounds) = process.many(ctx, util.resolve-body(ctx, body))

    ctx.transform = transform

    drawables = drawables.map(d => {
      if "segments" in d {
        d.segments = d.segments.map(((kind, ..pts)) => {
          (kind, ..pts.map(pt => {
            transform-vec(size, x, y, none, pt)
          }))
        })
      }
      if "pos" in d {
        d.pos = transform-vec(size, x, y, none, d.pos)
      }
      return d
    })

    return (
      ctx: ctx,
      drawables: drawable.apply-transform(ctx.transform, drawables)
    )
  },))
}