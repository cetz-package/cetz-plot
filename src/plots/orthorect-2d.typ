#import "/src/cetz.typ": draw, matrix, process, util


#let make-ctx((x, y), size) = {
  assert(x != none, message: "X axis does not exist")
  assert(y != none, message: "Y axis does not exist")
  assert(size.at(0) > 0 and size.at(1) > 0, message: "Plot size must be > 0")

  let x-scale =  ((x.max - x.min) / size.at(0))
  let y-scale =  ((y.max - y.min) / size.at(1))

  if y.horizontal {
    (x-scale, y-scale) = (y-scale, x-scale)
  }

  return (x: x, y: y, size: size, x-scale: x-scale, y-scale: y-scale)
}

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
            transform-vec(size, (x, y, none), pt)
          }))
        })
      }
      if "pos" in d {
        d.pos = transform-vec(size, (x, y, none), d.pos)
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

#let draw-axes(
  (w,h), 
  axis-dict, 
  name: none,
  ..style
) = {
  let bottom = axis-dict.at("x", default: none)
  let top = axis-dict.at("x2", default: auto)
  let left = axis-dict.at("y", default: none)
  let right = axis-dict.at("y2", default: auto)

  if (top == auto){
    top = bottom
    top.is-mirror = true
  }

  if (right == auto){
    right = bottom
    right.is-mirror = true
  }

  draw.group(name: name, ctx => {
    draw.anchor("origin", (0, 0))

    // Handle style
    let style = style.named()
    style = styles.resolve(ctx.style, merge: style, root: "axes",
                           base: default-style-scientific)
    style = _prepare-style(ctx, style)

    // Compute ticks
    let x-ticks = compute-ticks(bottom, style)
    let y-ticks = compute-ticks(left, style)
    let x2-ticks = compute-ticks(top, style)
    let y2-ticks = compute-ticks(right, style)
  })
}