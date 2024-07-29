#import "/src/cetz.typ": draw, util, vector

#let _inset-axis-points(ctx, style, axis, start, end) = {
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

#let _draw-axis-line(start, end, axis, is-horizontal, style) = {
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
