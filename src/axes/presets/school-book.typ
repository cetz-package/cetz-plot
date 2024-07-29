#import "/src/cetz.typ": util, draw, styles, vector
#import "../style.typ": default-style, _prepare-style, _get-axis-style
#import "../draw.typ": _inset-axis-points, _draw-axis-line
#import "../grid.typ": draw-grid-lines
#import "../ticks.typ": *

#let default-style-schoolbook = util.merge-dictionary(default-style, (
  x: (stroke: auto, fill: none, mark: (start: none, end: "straight"),
    tick: (label: (anchor: "north"))),
  y: (stroke: auto, fill: none, mark: (start: none, end: "straight"),
    tick: (label: (anchor: "east"))),
  label: (offset: .1cm),
  origin: (label: (offset: .05cm)),
  padding: .1cm,   // Axis padding on both sides outsides the plotting area
  overshoot: .5cm, // Axis end "overshoot" out of the plotting area
  tick: (
    offset: -50%,
    minor-offset: -50%,
    length: .2cm,
    minor-length: 70%,
  ),
  shared-zero: $0$, // Show zero tick label at (0, 0)
))

// Draw two axes in a "school book" style
//
// - x-axis (axis): X axis
// - y-axis (axis): Y axis
// - size (array): Size (width, height)
// - x-position (number): X Axis position
// - y-position (number): Y Axis position
// - name (string): Object name
// - ..style (any): Style
#let school-book(x-axis, y-axis,
                 size: (1, 1),
                 x-position: 0,
                 y-position: 0,
                 name: none,
                 ..style) = {
  import draw: *

  group(name: name, ctx => {
    let (w, h) = size
    anchor("origin", (0, 0))

    let style = style.named()
    style = styles.resolve(
      ctx.style,
      merge: style,
      root: "axes",
      base: default-style-schoolbook)
    style = _prepare-style(ctx, style)

    let x-position = calc.min(calc.max(y-axis.min, x-position), y-axis.max)
    let y-position = calc.min(calc.max(x-axis.min, y-position), x-axis.max)
    let x-y = value-on-axis(y-axis, x-position) * h
    let y-x = value-on-axis(x-axis, y-position) * w

    let shared-zero = style.shared-zero != false and x-position == 0 and y-position == 0

    let x-ticks = compute-ticks(x-axis, style, add-zero: not shared-zero)
    let y-ticks = compute-ticks(y-axis, style, add-zero: not shared-zero)

    // Draw grid
    group(name: "grid", ctx => {
      let axes = (
        ("x", (0,0), (0,h), (+w,0), x-ticks, x-axis),
        ("y", (0,0), (w,0), (0,+h), y-ticks, y-axis),
      )

      for (name, start, end, direction, ticks, axis) in axes {
        if axis == none { continue }

        let style = _get-axis-style(ctx, style, name)
        on-layer(style.grid-layer, {
          draw-grid-lines(ctx, axis, ticks, start, end, direction, style)
        })
      }
    })

    // Draw axes
    group(name: "axes", {
      let axes = (
        ("x", (0, x-y), (w, x-y), (1, 0), false, x-ticks, x-axis),
        ("y", (y-x, 0), (y-x, h), (0, 1), true, y-ticks, y-axis),
      )
      let label-pos = (
        x: ("north", (0,-1)),
        y: ("east", (-1,0)),
      )

      on-layer(style.axis-layer, {
        for (name, start, end, dir, flip, ticks, axis) in axes {
          let style = _get-axis-style(ctx, style, name)

          let pad = style.padding
          let overshoot = style.overshoot
          let vstart = vector.sub(start, vector.scale(dir, pad))
          let vend = vector.add(end, vector.scale(dir, pad + overshoot))
          let is-horizontal = name == "x"

          let (data-start, data-end) = _inset-axis-points(ctx, style, axis, start, end)
          group(name: "axis", {
            _draw-axis-line(vstart, vend, axis, is-horizontal, style)
            place-ticks-on-line(ticks, data-start, data-end, style, flip: flip)
          })

          if axis.label != none {
            let (content-anchor, offset-dir) = label-pos.at(name)

            let angle = if style.label.angle not in (none, auto) {
              style.label.angle
            } else { 0deg }
            if style.label.anchor not in (none, auto) {
              content-anchor = style.label.anchor
            }

            let offset = vector.scale(offset-dir, style.label.offset)
            content((rel: offset, to: vend),
              [#axis.label],
              angle: angle,
              anchor: content-anchor)
          }
        }

        if shared-zero {
          let pt = (rel: (-style.tick.label.offset, -style.tick.label.offset),
                     to: (y-x, x-y))
          let zero = if type(style.shared-zero) == content {
            style.shared-zero
          } else {
            $0$
          }
          content(pt, zero, anchor: "north-east")
        }
      })
    })
  })
}
