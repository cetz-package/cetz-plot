#let orthorect-2d() = {
  import "orthorect-2d.typ": make-ctx, data-viewport, draw-axes,
  import "transforms.typ": transform-vec

  return (
    make-ctx: make-ctx,
    data-viewport: data-viewport,
    draw-axes: draw-axes,
    transform-vec: transform-vec,
  )
}
