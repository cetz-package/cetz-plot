#import "/src/cetz.typ": draw, util, styles, vector
#import "/src/plot/styles.typ": default-style, prepare-style, get-axis-style
#import "/src/axes/axes.typ"

#import "grid.typ"
#import "axis.typ": draw-axis-line, inset-axis-points, place-ticks-on-line, place-ticks-on-radius
#import "transforms.typ": data-viewport, axis-viewport, transform-vec
#import "clipper.typ"

#let default-style-polar-2d = util.merge-dictionary(
  default-style, 
  (
    distal: (tick: (label: (anchor: "north-east", offset: -0.2))),
    angular: (tick: (label: (anchor: "center", offset: 0.35,), length: 5pt)),
    stroke: (cap: "square"),
    padding: 0,
  )
)

// TODO: Consider refactor
#let make-ctx((x, y), size) = {
  assert(x != none, message: "X axis does not exist")
  assert(y != none, message: "Y axis does not exist")
  assert(size.at(0) > 0 and size.at(1) > 0, message: "Plot size must be > 0")

  let x-scale =  ((x.max - x.min) / size.at(0))
  let y-scale =  ((y.max - y.min) / size.at(1))

  if y.horizontal {
    (x-scale, y-scale) = (y-scale, x-scale)
  }

  return (
    axes: (x, y),
    size: size, 
    x-scale: x-scale, 
    y-scale: y-scale,
    clip: ((x.min, y.min), (x.max, y.max)), // TODO: Change to radius
    transform-vec: transform-vec,
    compute-stroke-paths: clipper.compute-stroke-paths,
    compute-fill-paths: clipper.compute-fill-paths
  )
}

#let draw-axes(
  (w, h),
  axis-dict, 
  name: none,
  ..style
) = {
  let angular = axis-dict.at("x", default: none)
  let distal = axis-dict.at("y", default: none)

  let radius = calc.min(w, h) / 2

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
    })
  })
}
