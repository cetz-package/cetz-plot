#import "/src/cetz.typ": util, vector, draw

// Refactor opporunity: 
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
#let draw-lines(ctx, axis, ticks, radius, style) = {
  let offset = (0,0)
  if axis.inset != none {
    let (inset-low, inset-high) = axis.inset.map(v => util.resolve-number(ctx, v))
    offset = inset-low
  }
  let kind = _get-grid-type(axis)
  if kind == 0 {return}

  if axis.horizontal {
    for (distance, label, is-major) in ticks {
      let theta = distance * calc.pi * 2
      draw.line(
        (radius, radius), 
        (
          radius * (calc.cos(theta) + 1),
          radius * (calc.sin(theta) + 1)
        ), 
        stroke: if is-major and (kind == 1 or kind == 3) {
          style.grid.stroke
        } else if not is-major and kind >= 2 {
          style.minor-grid.stroke
        }
      )
    }
  } else {  
    for (distance, label, is-major) in ticks {
      draw.circle( 
        (radius, radius), 
        radius: distance * radius, 
        stroke: if is-major and (kind == 1 or kind == 3) {
          style.grid.stroke
        } else if not is-major and (kind >= 2) {
          style.minor-grid.stroke
        }
      )
    }
  }
}