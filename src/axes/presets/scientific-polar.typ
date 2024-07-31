#import "/src/cetz.typ": util, draw, styles, vector
#import "../style.typ": _prepare-style, _get-axis-style
#import "../draw.typ": _inset-axis-points, _draw-axis-line
#import "../grid.typ": draw-grid-lines
#import "../ticks.typ": *
#import "scientific.typ": default-style-scientific

// Default Scientific Style
#let default-style-scientific-polar = util.merge-dictionary(default-style-scientific, (
  distal: (tick: (label: (anchor: "north-east", offset: 0.25))),
  angular: (tick: (label: (anchor: "center", offset: 0.35))),
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
      circle( 
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

#let _draw-polar-axis-line(center, radius, axis, is-horizontal, style) = {
  let enabled = if axis != none and axis.show-break {
    axis.min > 0 or axis.max < 0
  } else { false }

  if enabled {
    // let size = if is-horizontal {
    //   (style.break-point.width, 0)
    // } else {
    //   (0, style.break-point.width, 0)
    // }

    // let up = if is-horizontal {
    //   (0, style.break-point.length)
    // } else {
    //   (style.break-point.length, 0)
    // }

    // let add-break(is-end) = {
    //   let a = ()
    //   let b = (rel: vector.scale(size, .3), update: false)
    //   let c = (rel: vector.add(vector.scale(size, .4), vector.scale(up, -1)), update: false)
    //   let d = (rel: vector.add(vector.scale(size, .6), vector.scale(up, +1)), update: false)
    //   let e = (rel: vector.scale(size, .7), update: false)
    //   let f = (rel: size)

    //   let mark = if is-end {
    //     style.at("mark", default: none)
    //   }
    //   draw.line(a, b, c, d, e, f, stroke: style.stroke, mark: mark)
    // }

    // draw.merge-path({
    //   draw.move-to(start)
    //   if axis.min > 0 {
    //     add-break(false)
    //     draw.line((rel: size, to: start), end, mark: style.at("mark", default: none))
    //   } else if axis.max < 0 {
    //     draw.line(start, (rel: vector.scale(size, -1), to: end))
    //     add-break(true)
    //   }
    // }, stroke: style.stroke)
  } else {
    draw.circle(center, radius: radius, stroke: style.stroke, mark: style.at("mark", default: none))
  }
}

#let place-ticks-on-radius(ticks, center, radius, style, flip: true) = {

  // Early exit
  let show-label = style.tick.label.show
  if (show-label not in (auto, true)) {return}

  let def(v, d) = {
    return if v == none or v == auto {d} else {v}
  }

  for (distance, label, is-major) in ticks {

    // Early exit for overlapping tick
    if (distance == 1){continue}

    let theta = (2 * distance) * calc.pi
    let dist = radius

    let offset = style.tick.offset
    let length = if is-major { style.tick.length } else { style.tick.minor-length }
    if flip {
      offset *= -1
      length *= -1
    }

    let a = dist + offset
    let b = a + length

    draw.line(
      (a * calc.sin(theta) + radius, a * calc.cos(theta) + radius),
      (b * calc.sin(theta) + radius, b * calc.cos(theta) + radius),
      stroke: style.tick.stroke
    )

    if (label != none){
      let offset = style.tick.label.offset
      if flip {
        offset *= -1
        length *= -1
      }
    //   let c = vector.sub(if length <= 0 { b } else { a },
    //     vector.scale(norm, offset))

      let c = a - offset

      let angle = def(style.tick.label.angle, 0deg)
      let anchor = def(style.tick.label.anchor, "center")

      draw.content(
        (c * calc.sin(theta) + radius, c * calc.cos(theta) + radius), 
        [#label], 
        angle: angle, 
        anchor: anchor
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
                           base: default-style-scientific-polar)
    style = _prepare-style(ctx, style)

    // Compute ticks
    let x-ticks = compute-ticks(angular, style)
    let y-ticks = compute-ticks(distal, style)
    let radius = calc.min(w,h) / 2

    style.fill = luma(95%)

    // Draw frame
    if style.fill != none {
      on-layer(style.background-layer, {
        circle( (radius,radius), radius: radius, fill: style.fill, stroke: none)
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
        ("angular", (radius, radius), (radius, radius*2), (0, -1), false, x-ticks,  angular),
        ("distal",  (radius, radius), (radius, radius*2), (-1,0), true,  y-ticks,  distal,),
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


        if (name == "angular"){
          let (data-start, data-end) = _inset-axis-points(ctx, style, axis, start, end)

          let path = _draw-polar-axis-line(start, radius, axis, is-horizontal, style)
          on-layer(style.axis-layer, {
            group(name: "axis", {
              if draw-unset or axis != none {
                path;
                place-ticks-on-radius(ticks, start, radius, style)
              }
            })
          })
        } else {

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
      }
    })
  })
}
