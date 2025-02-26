#import "/src/cetz.typ" as cetz: draw, coordinate, util.resolve-number, vector

/// Possible chevron caps: #cetz.smartart.process.CHEVRON-CAPS
/// #example(```
/// for cap in smartart.process.CHEVRON-CAPS {
///   smartart.process.chevron(
///     ([Step 1], [Step 2]), spacing: 0,
///     start-cap: cap, middle-cap: cap, end-cap: cap)
///   translate(y: -1)
/// }
/// ```)
#let CHEVRON-CAPS = (
  "(", "<", "|", ">", ")"
)

#let _draw-arrow(
  start,
  end,
  height,
  fill,
  stroke,
  double: false,
  name: none
) = {
  let h2 = height / 2
  let h4 = height / 4
  draw.group(name: name, ctx => {
    let (ctx, p1) = coordinate.resolve(ctx, start)
    let (ctx, p2) = coordinate.resolve(ctx, end)
    let (x1, y1, _) = p1
    let (x2, y2, _) = p2
    let v = vector.sub(p2, p1)
    let d = vector.norm(v)
    let n = (-d.at(1), d.at(0))
    let len = vector.len(v)
    /*
        c
    a---b\
    p1    p2
    g---f/
        e
    */
    let a = vector.add(p1, vector.scale(n, h4))
    let b = vector.add(a, vector.scale(d, len * 2 / 3))
    let c = vector.add(b, vector.scale(n, h4))
    let e = vector.add(c, vector.scale(n, -height))
    let f = vector.add(e, vector.scale(n, h4))
    let g = vector.add(a, vector.scale(n, -h2))
    let pts = (
      a, b, c, p2, e, f, g
    )
    
    draw.line(
      ..pts,
      stroke: stroke,
      fill: fill,
      close: true
    )
    draw.anchor("start", p1)
    draw.anchor("end", p2)
    draw.anchor("center", (p1, 50%, p2))
    draw.anchor("default", (p1, 50%, p2))
  })
}

#let _draw-chevron(
  start,
  end,
  thickness,
  fill,
  stroke,
  start-cap,
  end-cap,
  cap-ratio,
  offset-start,
  offset-end,
  name: none
) = {
  let h2 = thickness / 2
  let h4 = thickness / 4
  draw.group(name: name, ctx => {
    let (ctx, p1) = coordinate.resolve(ctx, start)
    let (ctx, p2) = coordinate.resolve(ctx, end)


    draw.anchor("center", (p1, 50%, p2))
    draw.anchor("default", (p1, 50%, p2))
    
    let v = vector.sub(p2, p1)
    let d = vector.norm(v)
    let n = (d.at(1), d.at(0))

    /*
     >    |     <    )
    sa    sa   sa   sa,
     \    |    /       \
      sb  |   sb       |sb
     /    |    \       /
    sz    sz   sz   sz´
    */

    let cap-width = thickness * cap-ratio / 100%

    if offset-start and start-cap in ("(", "<") {
      p1 = vector.add(p1, vector.scale(d, cap-width))
    }

    if offset-end and end-cap in (")", ">") {
      p2 = vector.sub(p2, vector.scale(d, cap-width))
    }

    // Start cap
    let sb = if start-cap in ("(", "<") {
      vector.sub(p1, vector.scale(d, cap-width))
    } else {
      p1
    }
    let sa = vector.add(p1, vector.scale(n, h2))
    if start-cap in (")", ">") {
      sa = vector.sub(sa, vector.scale(d, cap-width))
    }
    let sz = vector.sub(sa, vector.scale(n, thickness))
    
    // End cap
    let eb = if end-cap in (")", ">") {
      vector.add(p2, vector.scale(d, cap-width))
    } else {
      p2
    }
    let ea = vector.add(p2, vector.scale(n, h2))
    if end-cap in ("(", "<") {
      ea = vector.add(ea, vector.scale(d, cap-width))
    }
    let ez = vector.sub(ea, vector.scale(n, thickness))
    
    draw.merge-path(
      {
        // Start cap
        if start-cap in ("(", ")") {
          draw.arc-through(sa, sb, sz)
        } else if start-cap == "|" {
          draw.line(sa, sz)
        } else {
          draw.line(sa, sb, sz)
        }
        
        // End cap
        if end-cap in ("(", ")") {
          draw.arc-through(ez, eb, ea)
        } else if end-cap == "|" {
          draw.line(ez, ea)
        } else {
          draw.line(ez, eb, ea)
        }
      },
      stroke: stroke,
      fill: fill,
      close: true
    )
    draw.anchor("start", p1)
    draw.anchor("end", p2)
  })
}

#let _get-steps-sizes(steps, ctx, style, step-style-at) = {
  let sizes = steps.enumerate().map(p => {
    let (i, step) = p
    let step-style = style.steps + step-style-at(i)
    let padding = resolve-number(ctx, step-style.padding)
    let max-width = resolve-number(ctx, step-style.max-width)
    max-width -= 2 * padding
    let m = measure(step, width: max-width * ctx.length)
    let w = resolve-number(ctx, m.width)
    let h = resolve-number(ctx, m.height)
    return (w, h)
  })

  let largest-width = calc.max(..sizes.map(s => s.first()))
  let highest-height = calc.max(..sizes.map(s => s.last()))

  return (sizes, largest-width, highest-height)
}

#let _get-style-at-func(style) = {
  if type(style) == function {
    style
  } else if type(style) == array {
    i => {
      let s = style.at(calc.rem(i, style.len()))
      if type(s) == color or type(s) == gradient {
        (fill: s)
      } else {
        s
      }
    }
  } else if type(style) == gradient {
    i => (fill: style.sample(i / (steps.len() - 1) * 100%))
  } else {
    i => (:)
  }
}

#let _pos-to-anchor(pos) = {
  if pos == left {return "west"}
  if pos == right {return "east"}
  if pos == top {return "north"}
  if pos == bottom {return "south"}
  panic("Cannot convert alignment " + repr(pos) + " to cardinal anchor")
}

#let _dir-to-anchors(dir) = {
  return (
    _pos-to-anchor(dir.start()),
    _pos-to-anchor(dir.end())
  )
}

#let _dir-to-str(dir) = {
  if dir == ttb {return "ttb"}
  if dir == btt {return "btt"}
  if dir == ltr {return "ltr"}
  if dir == rtl {return "rtl"}
  panic("Invalid direction " + repr(dir))
}

#let _draw-step-content(step, name, width) = {
  draw.content(
    name + ".center",
    box(
      width: width,
      align(center)[
        #set text(bottom-edge: "baseline")
        #step
      ]
    ),
    anchor: "center"
  )
}

#let _draw-step(ctx, step, pos, dir, style, name, w, h) = {
  let padding = resolve-number(ctx, style.padding)
  let radius = resolve-number(ctx, style.radius)

  let tl = (
    rel: (
      ltr: (0, h / 2 + padding),
      rtl: (-w - padding * 2, h / 2 + padding),
      btt: (-w / 2 - padding, h + 2 * padding),
      ttb: (-w / 2 - padding, 0),
    ).at(_dir-to-str(dir)),
    to: pos
  )
  let br = (
    rel: (w + padding * 2, -h - padding * 2),
    to: tl
  )

  draw.rect(
    tl, br,
    name: name,
    stroke: style.stroke,
    fill: style.fill,
    radius: radius
  )
  _draw-step-content(step, name, w * ctx.length)
}

#let _draw-arc-arrow(
  start-angle,
  end-angle,
  radius,
  height,
  fill,
  stroke,
  double: false,
  name: none
) = {
  let h2 = height / 2
  let h4 = height / 4
  let angle-range = end-angle - start-angle
  let arrow-angle = if angle-range < 0deg {
    calc.min(-1deg, angle-range * 0.1)
  } else {
    calc.max(1deg, angle-range * 0.1)
  }
  let arrow-angle = (h2 / radius) * (180deg / calc.pi)
  if angle-range < 0deg {
    arrow-angle *= -1
  }
  draw.group(name: name, ctx => {
    let pre-end-angle = end-angle - arrow-angle
    let mid-angle = (angle-range - arrow-angle) / 2 + start-angle
    let radius-int = radius - h4
    let radius-ext = radius + h4

    /*
         c     re2
    a-m1-b\    re
    p1     p2  r
    g-m2-f/    ri
         e     ri2
    */
    let p1 = (start-angle, radius)
    let a = (start-angle, radius-ext)
    let m1 = (mid-angle, radius-ext)
    let b = (pre-end-angle, radius-ext)
    let p2 = (end-angle, radius)
    let f = (pre-end-angle, radius-int)
    let m2 = (mid-angle, radius-int)
    let g = (start-angle, radius-int)
    
    let dx = calc.cos(end-angle)
    let dy = calc.sin(end-angle)
    let c = (rel: (dx * h4, dy * h4), to: b)
    let e = (rel: (-dx * h4, -dy * h4), to: f)
    
    draw.merge-path(
      {
        draw.arc-through(a, m1, b)
        draw.line((), c, p2, e, f)
        draw.arc-through((), m2, g)
      },
      stroke: stroke,
      fill: fill,
      close: true
    )

    let center = (angle-range / 2 + start-angle, radius)
    draw.anchor("start", p1)
    draw.anchor("end", p2)
    draw.anchor("center", center)
    draw.anchor("default", center)
  })
}