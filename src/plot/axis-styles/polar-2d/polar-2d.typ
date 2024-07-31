#import "/src/cetz.typ": draw, util, styles, vector
#import "/src/plot/styles.typ": default-style, prepare-style, get-axis-style
#import "/src/axes/axes.typ"

#import "grid.typ"
#import "axis.typ": draw-axis-line, inset-axis-points, place-ticks-on-line, place-ticks-on-radius
#import "transforms.typ": data-viewport, axis-viewport, 

#let default-style-polar-2d = util.merge-dictionary(
  default-style, 
  (
    distal: (tick: (label: (anchor: "north-east", offset: -0.2))),
    angular: (tick: (label: (anchor: "center", offset: 0.35,), length: 5pt)),
    stroke: (cap: "square"),
    padding: 0,
  )
)

// Consider refactor
#let make-ctx((x, y), size) = {
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

#let draw-axes(
  (w,h), 
  axis-dict, 
  name: none,
  ..style
) = {
  let angular = axis-dict.at("x", default: none)
  let distal = axis-dict.at("y", default: none)

  let radius = calc.min(w,h)/2

  draw.group(name: name, ctx => {
    draw.anchor("origin", (radius, radius))

    // Handle style
    let style = style.named()
    style = styles.resolve(
      ctx.style, 
      merge: style, 
      root: "axes",
      base: default-style-polar-2d
    )
    style = prepare-style(ctx, style)

    // Compute ticks
    let angular-ticks = axes.ticks.compute-ticks(angular, style)
    let distal-ticks = axes.ticks.compute-ticks(distal, style)

    // Draw frame
    if style.fill != none {
      draw.on-layer(style.background-layer, {
        draw.circle("origin", radius: radius, fill: style.fill, stroke: none)
      })
    }

    // Draw grid
    draw.group(name: "grid", ctx => {
      let axes = (
        ("x", angular-ticks, angular),
        ("y", distal-ticks,  distal)
      )
      for (name, ticks, axis) in axes {
        if axis == none { continue }

        let style = get-axis-style(ctx, style, name)
        draw.on-layer(style.grid-layer, {
          grid.draw-lines(ctx, axis, ticks, radius, style)
        })
      }
    })
    
    // Draw axes
    draw.group(name: "axes", {

      // Render distal
      draw.on-layer(style.axis-layer, {
          draw.group(name: "axis", {
            if distal != none {
              // To do: Allow finer control over placement
              draw.line(
                "origin", (rel:(0, radius)), 
                stroke: style.stroke, 
                mark: style.at("mark", default: none)
              )

              place-ticks-on-line(
                distal-ticks, 
                (radius, radius), 
                (radius, radius*2), 
                prepare-style(ctx, style.distal),
              )
            }
          })
      })

      draw.on-layer(style.axis-layer, {
          draw.group(name: "axis", {
            if angular != none {
              // To do: Allow finer control over placement
              draw.circle(
                "origin",
                radius: radius,
                stroke: style.stroke, 
                mark: style.at("mark", default: none)
              )

              place-ticks-on-radius(
                angular-ticks, 
                (radius),
                prepare-style(ctx, style.angular), 
              )
            }
          })
      })
      // let axes = (
      //   ("angular", (0, 0), (w, 0), (0, -1), false, angular-ticks, angular,),
      //   ("distal",   (0, 0), (0, h), (-1, 0), true,  distal-ticks, distal,),
      // )
      // let label-placement = (
      //   angular: ("south", "north", 0deg),
      //   distal:    ("north", "south", 0deg),
      // )

      // for (name, start, end, outsides, flip, ticks, axis) in axes {
      //   let style = get-axis-style(ctx, style, name)
      //   let is-mirror = axis == none or axis.at("is-mirror", default: false)
      //   let is-horizontal = name in ("bottom", "top")

      //   if style.padding != 0 {
      //     let padding = vector.scale(outsides, style.padding)
      //     start = vector.add(start, padding)
      //     end = vector.add(end, padding)
      //   }

      //   let (data-start, data-end) = inset-axis-points(ctx, style, axis, start, end)

      //   draw.on-layer(style.axis-layer, {
      //     draw.group(name: "axis", {
      //       if axis != none {
      //         draw-axis-line(start, end, axis, is-horizontal, style)
      //         place-ticks-on-line(ticks, data-start, data-end, style, flip: flip, is-mirror: is-mirror)
      //       }
      //     })

      //     if axis != none and axis.label != none and not is-mirror {
      //       let offset = vector.scale(outsides, style.label.offset)
      //       let (group-anchor, content-anchor, angle) = label-placement.at(name)

      //       if style.label.anchor != auto {
      //         content-anchor = style.label.anchor
      //       }
      //       if style.label.angle != auto {
      //         angle = style.label.angle
      //       }

      //       draw.content((rel: offset, to: "axis." + group-anchor),
      //         [#axis.label],
      //         angle: angle,
      //         anchor: content-anchor)
      //     }
      //   })
      // }
    })
  })
}