
#let make-ctx(x, y, size) = {
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

#let data-viewport(data, x, y, size, body, name: none) = {
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
  axes.axis-viewport(size, x, y, none, body, name: name)
}