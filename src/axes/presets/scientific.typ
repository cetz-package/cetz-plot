#import "/src/cetz.typ": util, draw, styles, vector
#import "../style.typ": default-style, _prepare-style, _get-axis-style
#import "../draw.typ": _inset-axis-points, _draw-axis-line
#import "../grid.typ": draw-grid-lines
#import "../ticks.typ": *

// Default Scientific Style
#let default-style-scientific = util.merge-dictionary(default-style, (
  left:   (tick: (label: (anchor: "east"))),
  bottom: (tick: (label: (anchor: "north"))),
  right:  (tick: (label: (anchor: "west"))),
  top:    (tick: (label: (anchor: "south"))),
  stroke: (cap: "square"),
  padding: 0,
))

// Draw up to four axes in an "scientific" style at origin (0, 0)
//
// - size (array): Size (width, height)
// - left (axis): Left (y) axis
// - bottom (axis): Bottom (x) axis
// - right (axis): Right axis
// - top (axis): Top axis
// - name (string): Object name
// - draw-unset (bool): Draw axes that are set to `none`
// - ..style (any): Style
#let scientific(size: (1, 1),
                left: none,
                right: auto,
                bottom: none,
                top: auto,
                draw-unset: true,
                name: none,
                ..style) = {
  import draw: *

  if right == auto {
    if left != none {
      right = left; right.is-mirror = true
    } else {
      right = none
    }
  }
  if top == auto {
    if bottom != none {
      top = bottom; top.is-mirror = true
    } else {
      top = none
    }
  }

  group(name: name, ctx => {
    let (w, h) = size
    anchor("origin", (0, 0))

    let style = style.named()
    style = styles.resolve(ctx.style, merge: style, root: "axes",
                           base: default-style-scientific)
    style = _prepare-style(ctx, style)

    // Compute ticks
    let x-ticks = compute-ticks(bottom, style)
    let y-ticks = compute-ticks(left, style)
    let x2-ticks = compute-ticks(top, style)
    let y2-ticks = compute-ticks(right, style)

    // Draw frame
    if style.fill != none {
      on-layer(style.background-layer, {
        rect((0,0), (w,h), fill: style.fill, stroke: none)
      })
    }

    // Draw grid
    group(name: "grid", ctx => {
      let axes = (
        ("bottom", (0,0), (0,h), (+w,0), x-ticks,  bottom),
        ("top",    (0,h), (0,0), (+w,0), x2-ticks, top),
        ("left",   (0,0), (w,0), (0,+h), y-ticks,  left),
        ("right",  (w,0), (0,0), (0,+h), y2-ticks, right),
      )
      for (name, start, end, direction, ticks, axis) in axes {
        if axis == none { continue }

        let style = _get-axis-style(ctx, style, name)
        let is-mirror = axis.at("is-mirror", default: false)

        if not is-mirror {
          on-layer(style.grid-layer, {
            draw-grid-lines(ctx, axis, ticks, start, end, direction, style)
          })
        }
      }
    })

    // Draw axes
    group(name: "axes", {
      let axes = (
        ("bottom", (0, 0), (w, 0), (0, -1), false, x-ticks,  bottom,),
        ("top",    (0, h), (w, h), (0, +1), true,  x2-ticks, top,),
        ("left",   (0, 0), (0, h), (-1, 0), true,  y-ticks,  left,),
        ("right",  (w, 0), (w, h), (+1, 0), false, y2-ticks, right,)
      )
      let label-placement = (
        bottom: ("south", "north", 0deg),
        top:    ("north", "south", 0deg),
        left:   ("west", "south", 90deg),
        right:  ("east", "north", 90deg),
      )

      for (name, start, end, outsides, flip, ticks, axis) in axes {
        let style = _get-axis-style(ctx, style, name)
        let is-mirror = axis == none or axis.at("is-mirror", default: false)
        let is-horizontal = name in ("bottom", "top")

        if style.padding != 0 {
          let padding = vector.scale(outsides, style.padding)
          start = vector.add(start, padding)
          end = vector.add(end, padding)
        }

        let (data-start, data-end) = _inset-axis-points(ctx, style, axis, start, end)

        let path = _draw-axis-line(start, end, axis, is-horizontal, style)
        on-layer(style.axis-layer, {
          group(name: "axis", {
            if draw-unset or axis != none {
              path;
              place-ticks-on-line(ticks, data-start, data-end, style, flip: flip, is-mirror: is-mirror)
            }
          })

          if axis != none and axis.label != none and not is-mirror {
            let offset = vector.scale(outsides, style.label.offset)
            let (group-anchor, content-anchor, angle) = label-placement.at(name)

            if style.label.anchor != auto {
              content-anchor = style.label.anchor
            }
            if style.label.angle != auto {
              angle = style.label.angle
            }

            content((rel: offset, to: "axis." + group-anchor),
              [#axis.label],
              angle: angle,
              anchor: content-anchor)
          }
        })
      }
    })
  })
}
