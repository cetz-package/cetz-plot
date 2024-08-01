#import "/src/cetz.typ": draw, util, styles, vector
#import "/src/plot/styles.typ": default-style, prepare-style, get-axis-style
#import "/src/axes/axes.typ"

#import "grid.typ"
#import "axis.typ": draw-axis-line, inset-axis-points, place-ticks-on-line
#import "transforms.typ": data-viewport, axis-viewport, transform-vec
#import "clipper.typ"

#let default-style-orthorect-2d = util.merge-dictionary(
  default-style, 
  (
    left:   (tick: (label: (anchor: "east"))),
    bottom: (tick: (label: (anchor: "north"))),
    right:  (tick: (label: (anchor: "west"))),
    top:    (tick: (label: (anchor: "south"))),
    stroke: (cap: "square"),
    padding: 0,
  )
)


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
    axes: (x,y), 
    size: size, 
    x-scale: x-scale, 
    y-scale: y-scale,
    clip: ((x.min, y.min), (x.max, y.max)),
    transform-vec: transform-vec,
    compute-stroke-paths: clipper.compute-stroke-paths,
    compute-fill-paths: clipper.compute-fill-paths
  )
}

#let draw-axes(
  (w,h), 
  axis-dict, 
  name: none,
  ..style
) = {
  let bottom = axis-dict.at("x", default: none)
  let top = axis-dict.at("x2", default: auto)
  let left = axis-dict.at("y", default: none)
  let right = axis-dict.at("y2", default: auto)

  if (top == auto){
    top = bottom
    top.is-mirror = true
  }

  if (right == auto){
    right = left
    right.is-mirror = true
  }

  draw.group(name: name, ctx => {
    draw.anchor("origin", (0, 0))

    // Handle style
    let style = style.named()
    style = styles.resolve(
      ctx.style, 
      merge: style, 
      root: "axes",
      base: default-style-orthorect-2d
    )
    style = prepare-style(ctx, style)

    // Compute ticks
    let x-ticks = axes.ticks.compute-ticks(bottom, style)
    let y-ticks = axes.ticks.compute-ticks(left, style)
    let x2-ticks = axes.ticks.compute-ticks(top, style)
    let y2-ticks = axes.ticks.compute-ticks(right, style)

    // Draw frame
    if style.fill != none {
      draw.on-layer(style.background-layer, {
        draw.rect((0,0), (w,h), fill: style.fill, stroke: none)
      })
    }

    // Draw grid
    draw.group(name: "grid", ctx => {
      let axes = (
        ("bottom", (0,0), (0,h), (+w,0), x-ticks,  bottom),
        ("top",    (0,h), (0,0), (+w,0), x2-ticks, top),
        ("left",   (0,0), (w,0), (0,+h), y-ticks,  left),
        ("right",  (w,0), (0,0), (0,+h), y2-ticks, right),
      )
      for (name, start, end, direction, ticks, axis) in axes {
        if axis == none { continue }

        let style = get-axis-style(ctx, style, name)
        let is-mirror = axis.at("is-mirror", default: false)

        if not is-mirror {
          draw.on-layer(style.grid-layer, {
            grid.draw-lines(ctx, axis, ticks, start, end, direction, style)
          })
        }
      }
    })
    
    // Draw axes
    draw.group(name: "axes", {
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
        let style = get-axis-style(ctx, style, name)
        let is-mirror = axis == none or axis.at("is-mirror", default: false)
        let is-horizontal = name in ("bottom", "top")

        if style.padding != 0 {
          let padding = vector.scale(outsides, style.padding)
          start = vector.add(start, padding)
          end = vector.add(end, padding)
        }

        let (data-start, data-end) = inset-axis-points(ctx, style, axis, start, end)

        let path = draw-axis-line(start, end, axis, is-horizontal, style)
        draw.on-layer(style.axis-layer, {
          draw.group(name: "axis", {
            // if draw-unset or axis != none {
              path;
              place-ticks-on-line(ticks, data-start, data-end, style, flip: flip, is-mirror: is-mirror)
            // }
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

            draw.content((rel: offset, to: "axis." + group-anchor),
              [#axis.label],
              angle: angle,
              anchor: content-anchor)
          }
        })
      }
    })
  })
}