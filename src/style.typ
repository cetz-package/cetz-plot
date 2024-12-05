#import "/src/cetz.typ"
#import cetz: draw

/// Default axis style
///
/// #show-parameter-block("tick-limit", "int", default: 100, [Upper major tick limit.])
/// #show-parameter-block("minor-tick-limit", "int", default: 1000, [Upper minor tick limit.])
/// #show-parameter-block("auto-tick-factors", "array", [List of tick factors used for automatic tick step determination.])
/// #show-parameter-block("auto-tick-count", "int", [Number of ticks to generate by default.])
///
/// #show-parameter-block("stroke", "stroke", [Axis stroke style.])
/// #show-parameter-block("label.offset", "number", [Distance to move axis labels away from the axis.])
/// #show-parameter-block("label.anchor", "anchor", [Anchor of the axis label to use for it's placement.])
/// #show-parameter-block("label.angle", "angle", [Angle of the axis label.])
/// #show-parameter-block("axis-layer", "float", [Layer to draw axes on (see @@on-layer() )])
/// #show-parameter-block("grid-layer", "float", [Layer to draw the grid on (see @@on-layer() )])
/// #show-parameter-block("background-layer", "float", [Layer to draw the background on (see @@on-layer() )])
/// #show-parameter-block("padding", "number", [Extra distance between axes and plotting area. For schoolbook axes, this is the length of how much axes grow out of the plotting area.])
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
/// #show-parameter-block("grid.minor-stroke", "stroke", [Minor grid line stroke style.])
/// #show-parameter-block("break-point.width", "number", [Axis break width along the axis.])
/// #show-parameter-block("break-point.length", "number", [Axis break length.])
///
/// #show-parameter-block("shared-zero", ("bool", "content"), default: "$0$", [School-book style axes only: Content to display at the plots origin (0,0). If set to `false`, nothing is shown. Having this set, suppresses auto-generated ticks for $0$!])
#let default-style = (
  mark: none,
  stroke: (paint: black, cap: "square"),
  fill: none,

  padding: (0cm, 0cm),

  show-zero: true,
  zero-label: $0$,

  axis-layer: 0,
  tick-layer: 0,
  grid-layer: 0,

  tick: (
    stroke: black + 1pt,
    minor-stroke: black + .5pt,

    offset: 0cm,
    length: .2cm,
    minor-offset: 0cm,
    minor-length: .1cm,
    flip: false,

    label: (
      "show": auto,
      offset: .1cm,
      angle: 0deg,
      anchor: "center",
      draw: (pos, body, angle, anchor) => {
        draw.content(pos, body, angle: angle, anchor: anchor)
      },
    ),
  ),

  grid: (
    stroke: gray + .5pt,
    minor-stroke: gray + .25pt,
  ),

  label: (
    angle: auto,
    offset: .5em,
    anchor: auto,
  ),

  // Overrides
  x: (
    tick: (
      label: (
        anchor: "north",
      ),
    ),
  ),
  y: (
    tick: (
      label: (
        anchor: "east",
      ),
    ),
  ),
  u: (
    tick: (
      label: (
        anchor: "south",
      ),
    ),
  ),
  v: (
    tick: (
      label: (
        anchor: "west",
      ),
    ),
  ),
  distal: (
    tick: (
      label: (
        anchor: "east",
      )
    )
  ),
)

#let prepare-style(ptx, style) = {
  let ctx = ptx.cetz-ctx
  let resolve-number = cetz.util.resolve-number.with(ctx)
  let relative-to(val, to) = {
    return if type(val) == ratio {
      val * to
    } else {
      val
    }
  }
  let resolve-relative-number(val, to) = {
    return resolve-number(relative-to(val, to))
  }

  if type(style.padding) != array {
    style.padding = (style.padding,) * 2
  }
  style.padding = style.padding.map(resolve-number)

  style.tick.offset = resolve-number(style.tick.offset)
  style.tick.length = resolve-number(style.tick.length)
  style.tick.minor-offset = resolve-relative-number(style.tick.minor-offset, style.tick.offset)
  style.tick.minor-length = resolve-relative-number(style.tick.minor-length, style.tick.length)

  style.tick.label.offset = resolve-number(style.tick.label.offset)

  style.label.offset = resolve-number(style.label.offset)

  return style
}

/// Get merged (sub) style for an axis
#let get-axis-style(ptx, style, name) = {
  return prepare-style(ptx, if name in style {
    cetz.util.merge-dictionary(style, style.at(name, default: (:)))
  } else {
    style
  })
}
