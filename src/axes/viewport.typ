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

  let (x,y,) =  if (
    x-axis.at("polar", default: false) or 
    y-axis.at("polar", default: false)
  ) {

    let radius = calc.min(..size)
    let x-norm = (vec.at(0) - x-axis.min) / (x-axis.max - x-axis.min)
    let y-norm = (vec.at(1) - y-axis.min) / (y-axis.max - y-axis.min)
    let theta = 2 * calc.pi * x-norm
    let dist = (radius/2) * y-norm
    let x = dist * calc.cos(theta)
    let y = dist * calc.sin(theta)

    (radius/2 + x, radius/2 + y)

  } else {
    for (dim, axis) in (x-axis, y-axis).enumerate() {
      let s = size.at(dim) - axis.inset.sum()
      let o = axis.inset.at(0)

      let transform-func(n) = if (axis.mode == "log") {
        calc.log(calc.max(n, util.float-epsilon), base: axis.base)
      } else {n}

      let range = transform-func(axis.max) - transform-func(axis.min)
      let f = s / range

      ((transform-func(vec.at(dim)) - transform-func(axis.min)) * f + o,)
    }
  }

  return (x, y, 0)
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