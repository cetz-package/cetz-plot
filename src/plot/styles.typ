#import "/src/cetz.typ": util, styles

/// Default axis style
///
/// #show-parameter-block("tick-limit", "int", default: 100, [Upper major tick limit.])
/// #show-parameter-block("minor-tick-limit", "int", default: 1000, [Upper minor tick limit.])
/// #show-parameter-block("auto-tick-factors", "array", [List of tick factors used for automatic tick step determination.])
/// #show-parameter-block("auto-tick-count", "int", [Number of ticks to generate by default.])
/// #show-parameter-block("stroke", "stroke", [Axis stroke style.])
/// #show-parameter-block("label.offset", "number", [Distance to move axis labels away from the axis.])
/// #show-parameter-block("label.anchor", "anchor", [Anchor of the axis label to use for it's placement.])
/// #show-parameter-block("label.angle", "angle", [Angle of the axis label.])
/// #show-parameter-block("axis-layer", "float", [Layer to draw axes on (see @@on-layer() )])
/// #show-parameter-block("grid-layer", "float", [Layer to draw the grid on (see @@on-layer() )])
/// #show-parameter-block("background-layer", "float", [Layer to draw the background on (see @@on-layer() )])
/// #show-parameter-block("padding", "number", [Extra distance between axes and plotting area. For schoolbook axes, this is the length of how much axes grow out of the plotting area.])
/// #show-parameter-block("overshoot", "number", [School-book style axes only: Extra length to add to the end (right, top) of axes.])
/// #show-parameter-block("tick.stroke", "stroke", [Major tick stroke style.])
/// #show-parameter-block("tick.minor-stroke", "stroke", [Minor tick stroke style.])
/// #show-parameter-block("tick.offset", ("number", "ratio"), [Major tick offset along the tick's direction, can be relative to the length.])
/// #show-parameter-block("tick.minor-offset", ("number", "ratio"), [Minor tick offset along the tick's direction, can be relative to the length.])
/// #show-parameter-block("tick.length", ("number"), [Major tick length.])
/// #show-parameter-block("tick.minor-length", ("number", "ratio"), [Minor tick length, can be relative to the major tick length.])
/// #show-parameter-block("tick.label.offset", ("number"), [Major tick label offset away from the tick.])
/// #show-parameter-block("tick.label.angle", ("angle"), [Major tick label angle.])
/// #show-parameter-block("tick.label.anchor", ("anchor"), [Anchor of major tick labels used for positioning.])
/// #show-parameter-block("tick.label.show", ("auto", "bool"), default: auto, [Set visibility of tick labels. A value of `auto` shows tick labels for all but mirrored axes.])
/// #show-parameter-block("grid.stroke", "stroke", [Major grid line stroke style.])
/// #show-parameter-block("break-point.width", "number", [Axis break width along the axis.])
/// #show-parameter-block("break-point.length", "number", [Axis break length.])
/// #show-parameter-block("minor-grid.stroke", "stroke", [Minor grid line stroke style.])
/// #show-parameter-block("shared-zero", ("bool", "content"), default: "$0$", [School-book style axes only: Content to display at the plots origin (0,0). If set to `false`, nothing is shown. Having this set, suppresses auto-generated ticks for $0$!])
#let default-style = (
  tick-limit: 100,
  minor-tick-limit: 1000,
  auto-tick-factors: (1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10), // Tick factor to try
  auto-tick-count: 11,  // Number of ticks the plot tries to place
  fill: none,
  stroke: auto,
  label: (
    offset: .2cm,       // Axis label offset
    anchor: auto,       // Axis label anchor
    angle:  auto,       // Axis label angle
  ),
  axis-layer: 0,
  grid-layer: 0,
  background-layer: 0,
  padding: 0,
  tick: (
    fill: none,
    stroke: black + 1pt,
    minor-stroke: black + .5pt,
    offset: 0,
    minor-offset: 0,
    length: .1cm,       // Tick length: Number
    minor-length: 70%,  // Minor tick length: Number, Ratio
    label: (
      offset: .15cm,    // Tick label offset
      angle:  0deg,     // Tick label angle
      anchor: auto,     // Tick label anchor
      "show": auto,     // Show tick labels for axes in use
    )
  ),
  break-point: (
    width: .75cm,
    length: .15cm,
  ),
  grid: (
    stroke: (paint: gray.lighten(50%), thickness: 1pt),
  ),
  minor-grid: (
    stroke: (paint: gray.lighten(50%), thickness: .5pt),
  ),
)

#let prepare-style(ctx, style) = {
  if type(style) != dictionary { return style }

  let res = util.resolve-number.with(ctx)
  let rel-to(v, to) = {
    if type(v) == ratio {
      return v * to / 100%
    } else {
      return res(v)
    }
  }

  style.tick.length = res(style.tick.length)
  style.tick.offset = rel-to(style.tick.offset, style.tick.length)
  style.tick.minor-length = rel-to(style.tick.minor-length, style.tick.length)
  style.tick.minor-offset = rel-to(style.tick.minor-offset, style.tick.minor-length)
  style.tick.label.offset = res(style.tick.label.offset)

  // Break points
  // style.break-point.width = res(style.break-point.width)
  // style.break-point.length = res(style.break-point.length)

  // Padding
  // style.padding = res(style.padding)

  if "overshoot" in style {
    style.overshoot = res(style.overshoot)
  }

  return style
}

#let get-axis-style(ctx, style, name) = {
  if not name in style {
    return style
  }

  style = styles.resolve(style, merge: style.at(name))
  return prepare-style(ctx, style)
}