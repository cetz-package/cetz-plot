#import "/src/cetz.typ": draw, util, vector

#let inset-axis-points(ctx, style, axis, start, end) = {
  if axis == none { return (start, end) }

  let (low, high) = axis.inset.map(v => util.resolve-number(ctx, v))

  let is-horizontal = start.at(1) == end.at(1)
  if is-horizontal {
    start = vector.add(start, (low, 0))
    end = vector.sub(end, (high, 0))
  } else {
    start = vector.add(start, (0, low))
    end = vector.sub(end, (0, high))
  }
  return (start, end)
}

#let draw-axis-line(start, end, axis, is-horizontal, style) = {
  let enabled = if axis != none and axis.show-break {
    axis.min > 0 or axis.max < 0
  } else { false }

  if enabled {
    let size = if is-horizontal {
      (style.break-point.width, 0)
    } else {
      (0, style.break-point.width, 0)
    }

    let up = if is-horizontal {
      (0, style.break-point.length)
    } else {
      (style.break-point.length, 0)
    }

    let add-break(is-end) = {
      let a = ()
      let b = (rel: vector.scale(size, .3), update: false)
      let c = (rel: vector.add(vector.scale(size, .4), vector.scale(up, -1)), update: false)
      let d = (rel: vector.add(vector.scale(size, .6), vector.scale(up, +1)), update: false)
      let e = (rel: vector.scale(size, .7), update: false)
      let f = (rel: size)

      let mark = if is-end {
        style.at("mark", default: none)
      }
      draw.line(a, b, c, d, e, f, stroke: style.stroke, mark: mark)
    }

    draw.merge-path({
      draw.move-to(start)
      if axis.min > 0 {
        add-break(false)
        draw.line((rel: size, to: start), end, mark: style.at("mark", default: none))
      } else if axis.max < 0 {
        draw.line(start, (rel: vector.scale(size, -1), to: end))
        add-break(true)
      }
    }, stroke: style.stroke)
  } else {
    draw.line(start, end, stroke: style.stroke, mark: style.at("mark", default: none))
  }
}

// Place a list of tick marks and labels along a path
#let place-ticks-on-line(ticks, start, stop, style, flip: false, is-mirror: false) = {
  let dir = vector.sub(stop, start)
  let norm = vector.norm((-dir.at(1), dir.at(0), dir.at(2, default: 0)))

  let def(v, d) = {
    return if v == none or v == auto {d} else {v}
  }

  let show-label = style.tick.label.show
  if show-label == auto {
    show-label = not is-mirror
  }

  for (distance, label, is-major) in ticks {
    let offset = style.tick.offset
    let length = if is-major { style.tick.length } else { style.tick.minor-length }
    if flip {
      offset *= -1
      length *= -1
    }

    let pt = vector.lerp(start, stop, distance)
    let a = vector.add(pt, vector.scale(norm, offset))
    let b = vector.add(a, vector.scale(norm, length))

    draw.line(a, b, stroke: style.tick.stroke)

    if show-label and label != none {
      let offset = style.tick.label.offset
      if flip {
        offset *= -1
        length *= -1
      }

      let c = vector.sub(if length <= 0 { b } else { a },
        vector.scale(norm, offset))

      let angle = def(style.tick.label.angle, 0deg)
      let anchor = def(style.tick.label.anchor, "center")

      draw.content(c, [#label], angle: angle, anchor: anchor)
    }
  }
}

#let place-ticks-on-radius(ticks, radius, style) = {
  
  let center = (radius,radius)

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

    let a = dist + offset
    let b = a - length

    draw.line(
      (a * calc.sin(theta) + radius, a * calc.cos(theta) + radius),
      (b * calc.sin(theta) + radius, b * calc.cos(theta) + radius),
      stroke: style.tick.stroke
    )

    if (label != none){
      let offset = style.tick.label.offset

    //   let c = vector.sub(if length <= 0 { b } else { a },
    //     vector.scale(norm, offset))

      let c = a + offset

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