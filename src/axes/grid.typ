#import "/src/cetz.typ": util, vector, draw

#let _get-grid-type(axis) = {
  let grid = axis.ticks.at("grid", default: false)
  if grid == "major" or grid == true { return 1 }
  if grid == "minor" { return 2 }
  if grid == "both" { return 3 }
  return 0
}

// Draw grid lines for the ticks of an axis
//
// - cxt (context):
// - axis (dictionary): The axis
// - ticks (array): The computed ticks
// - low (vector): Start position of a grid-line at tick 0
// - high (vector): End position of a grid-line at tick 0
// - dir (vector): Normalized grid direction vector along the grid axis
// - style (style): Axis style
#let draw-grid-lines(ctx, axis, ticks, low, high, dir, style) = {
  let offset = (0,0)
  if axis.inset != none {
    let (inset-low, inset-high) = axis.inset.map(v => util.resolve-number(ctx, v))
    offset = vector.scale(vector.norm(dir), inset-low)
    dir = vector.sub(dir, vector.scale(vector.norm(dir), inset-low + inset-high))
  }

  let kind = _get-grid-type(axis)
  if kind > 0 {
    for (distance, label, is-major) in ticks {
      let offset = vector.add(vector.scale(dir, distance), offset)
      let start = vector.add(low, offset)
      let end = vector.add(high, offset)

      // Draw a major line
      if is-major and (kind == 1 or kind == 3) {
        draw.line(start, end, stroke: style.grid.stroke)
      }
      // Draw a minor line
      if not is-major and kind >= 2 {
        draw.line(start, end, stroke: style.minor-grid.stroke)
      }
    }
  }
}