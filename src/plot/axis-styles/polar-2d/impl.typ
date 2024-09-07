#let polar-2d(..args) = {
  import "polar-2d.typ": make-ctx, data-viewport, draw-axes
  import "transforms.typ": transform-vec

  return (
    make-ctx: make-ctx,
    data-viewport: data-viewport,
    draw-axes: draw-axes.with(..args),
    transform-vec: transform-vec,
  )
}
