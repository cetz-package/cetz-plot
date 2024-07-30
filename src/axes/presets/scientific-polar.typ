#import "/src/cetz.typ": util, draw, styles, vector
#import "../style.typ": _prepare-style, _get-axis-style
#import "../draw.typ": _inset-axis-points, _draw-axis-line
#import "../grid.typ": draw-grid-lines
#import "../ticks.typ": *
#import "scientific.typ": default-style-scientific

// Default Scientific Style
#let default-style-scientific-polar = util.merge-dictionary(default-style-scientific, (
  left:   (tick: (label: (anchor: "east"))),
  bottom: (tick: (label: (anchor: "north"))),
  right:  (tick: (label: (anchor: "west"))),
  top:    (tick: (label: (anchor: "south"))),
  stroke: (cap: "square"),
  padding: 0,
))

#let _get-grid-type(axis) = {
  let grid = axis.ticks.at("grid", default: false)
  if grid == "major" or grid == true { return 1 }
  if grid == "minor" { return 2 }
  if grid == "both" { return 3 }
  return 0
}

#let _draw-polar-grid-lines(ctx, name, axis, ticks, radius, style) = {

  import draw: *

  let offset = (0,0)
  if axis.inset != none {
    let (inset-low, inset-high) = axis.inset.map(v => util.resolve-number(ctx, v))
    offset = inset-low
  }
  let kind = _get-grid-type(axis)
  if kind == 0 {return}

  if name == "angular" {
    for (distance, label, is-major) in ticks {
      let theta = distance * calc.pi * 2
      draw.line(
        (0,0), 
        (radius * calc.cos(theta), radius * calc.sin(theta)), 
        stroke: if is-major and (kind == 1 or kind == 3) {
          style.grid.stroke
        } else if not is-major and kind >= 2 {
          style.minor-grid.stroke
        }
      )
    }
  } else {  
    for (distance, label, is-major) in ticks {
      circle( 
        (0,0), 
        radius: distance * radius, 
        stroke: if is-major and (kind == 1 or kind == 3) {
          style.grid.stroke
        } else if not is-major and kind >= 2 {
          style.minor-grid.stroke
        }
      )
    }
  }
}

#let scientific-polar(size: (1, 1),
                angular: none,
                distal: none,
                draw-unset: true,
                name: none,
                ..style) = {
  import draw: *

  group(name: name, ctx => {
    let (w, h) = size
    anchor("origin", (0, 0))

    let style = style.named()
    style = styles.resolve(ctx.style, merge: style, root: "axes",
                           base: default-style-scientific)
    style = _prepare-style(ctx, style)

    // Compute ticks
    let x-ticks = compute-ticks(angular, style)
    let y-ticks = compute-ticks(distal, style)
    let radius = calc.min(w,h)

    // Draw frame
    if style.fill != none {
      on-layer(style.background-layer, {
        circle( (0,0), radius: radius, fill: style.fill, stroke: none)
        // rect((0,0), (w,h), fill: style.fill, stroke: none)
      })
    }

    let axes = (
      ("angular", x-ticks, angular),
      ("distal", y-ticks, distal),
    )

    // Draw grid
    // To do: render radial and angular gridlines
    // To do: divide radius by 2!
    group(name: "grid", ctx => {

      for (name, ticks, axis) in axes {
        if axis == none { continue }
        let style = _get-axis-style(ctx, style, name)

        on-layer(style.grid-layer, {
          _draw-polar-grid-lines(ctx, name, axis, ticks, radius, style)
        })
      }

    })

    // Draw axes
    // To do: Handle label placement

    group(name: "axes", {
      let axes = (
        // ("angular", (0, 0), (w, 0), (0, -1), false, x-ticks,  angular,),
        ("distal",   (0, 0), (0, h), (-1, 0), true,  y-ticks,  distal,),
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

          
        })
      }
    })
  })
}
