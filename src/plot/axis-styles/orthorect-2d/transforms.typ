#import "/src/cetz.typ": draw, matrix, process, util, drawable

// Transform a single vector along a x, y and z axis
//
// - size (vector): Coordinate system size
// - x-axis (axis): X axis
// - y-axis (axis): Y axis
// - z-axis (axis): Z axis
// - vec (vector): Input vector to transform
// -> vector
#let transform-vec(size, axes, vec) = {

  let (x,y,) = for (dim, axis) in axes.enumerate() {

    let s = size.at(dim) - axis.inset.sum()
    let o = axis.inset.at(0)

    let transform-func(n) = if (axis.mode == "log") {
      calc.log(calc.max(n, util.float-epsilon), base: axis.base)
    } else {n}

    let range = transform-func(axis.max) - transform-func(axis.min)

    let f = s / range
    ((transform-func(vec.at(dim)) - transform-func(axis.min)) * f + o,)
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
#let axis-viewport(size,(x, y,), body, name: none) = {
  draw.group(name: name, (ctx => {
    let transform = ctx.transform

    ctx.transform = matrix.ident()
    let (ctx, drawables, bounds) = process.many(ctx, util.resolve-body(ctx, body))

    ctx.transform = transform

    drawables = drawables.map(d => {
      if "segments" in d {
        d.segments = d.segments.map(((kind, ..pts)) => {
          (kind, ..pts.map(pt => {
            transform-vec(size, (x, y), pt)
          }))
        })
      }
      if "pos" in d {
        d.pos = transform-vec(size, (x, y), d.pos)
      }
      return d
    })

    return (
      ctx: ctx,
      drawables: drawable.apply-transform(ctx.transform, drawables)
    )
  },))
}

#let data-viewport((x, y), size, body, name: none) = {
  if body == none or body == () { return }

  assert.ne(x.horizontal, y.horizontal,
    message: "Data must use one horizontal and one vertical axis!")

  // If y is the horizontal axis, swap x and y
  // coordinates by swapping the transformation
  // matrix columns.
  if y.horizontal {
    (x, y) = (y, x)
    body = draw.set-ctx(ctx => {
      ctx.transform = matrix.swap-cols(ctx.transform, 0, 1)
      return ctx
    }) + body
  }

  // Setup the viewport
  axis-viewport(size, (x,y), body, name: name)
}