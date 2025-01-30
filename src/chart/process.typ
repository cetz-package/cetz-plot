#import "/src/cetz.typ" as cetz: draw, styles, palette, coordinate, util.resolve-number, vector

#let process-basic-default-style = (
  stroke: auto,
  fill: auto,
  spacing: 0.2em,
  steps: (
    stroke: none,
    fill: none,
    radius: 0.2em,
    padding: 0.6em,
    max-width: 5em
  ),
  arrows: (
    stroke: none,
    fill: "steps",
    height: 1em,
    width: 1.2em
  )
)

#let process-bending-default-style = (
  stroke: auto,
  fill: auto,
  spacing: 0.2em,
  steps: (
    stroke: none,
    fill: none,
    radius: 0.2em,
    padding: 0.6em,
    max-width: 5em
  ),
  arrows: (
    stroke: none,
    fill: "steps",
    height: 1em,
    width: 1.2em
  ),
  layout: (
    max-stride: 3,
    flow: (ltr, ttb)
  )
)

#let CHEVRON-CAPS = (
  "(", "<", "|", ">", ")"
)

#let process-chevron-default-style = (
  stroke: auto,
  fill: auto,
  spacing: 0.2em,
  start-cap: ">",
  middle-cap: ">",
  end-cap: ">",
  start-in-cap: false,
  end-in-cap: false,
  steps: (
    stroke: none,
    fill: none,
    padding: 0.6em,
    max-width: 5em,
    cap-ratio: 50%
  )
)

#let _draw-arrow(
  start,
  end,
  height,
  fill,
  stroke,
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
    let n = (d.at(1), d.at(0))
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
    draw.anchor("start", sb)
    draw.anchor("end", eb)
  })
}

#let basic(
  steps,
  arrow-style: auto,
  step-style: palette.red,
  equal-width: false,
  equal-height: false,
  dir: ltr,
  name: none,
  ..style
) = {
  draw.group(name: name, ctx => {
    draw.anchor("default", (0, 0))

    let style = styles.resolve(
      ctx.style,
      merge: style.named(),
      root: "process-basic",
      base: process-basic-default-style,
    )

    let spacing = resolve-number(ctx, style.spacing)

    let step-style-at = if type(step-style) == function {
      step-style
    } else if type(step-style) == array {
      i => {
        let s = step-style.at(calc.rem(i, step-style.len()))
        if type(s) == color or type(s) == gradient {
          (fill: s)
        } else {
          s
        }
      }
    } else if type(step-style) == gradient {
      i => (fill: step-style.sample(i / (steps.len() - 1) * 100%))
    }

    let arrow-style-at = if type(arrow-style) == function {
      arrow-style
    } else if type(arrow-style) == array {
      i => {
        let s = arrow-style.at(calc.rem(i, arrow-style.len()))
        if type(s) == color or type(s) == gradient {
          (fill: s)
        } else {
          s
        }
      }
    } else if type(arrow-style) == gradient {
      i => (fill: arrow-style.sample(i / (steps.len() - 1) * 100%))
    } else {
      i => (:)
    }

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

    let vertical = dir in (ttb, btt)
    let reverse = dir in (rtl, ttb)
    let adapt-offset(offset, ..args) = {
      let offset = offset
      if vertical {
        if args.pos().len() != 0 {
          offset = args.pos().first()
        } else {
          offset = offset.rev()
        }
      }
      if reverse {
        offset = offset.map(v => -v)
      }
      return offset
    }

    let (anchor-1, anchor-2) = (
      ltr: ("west", "east"),
      rtl: ("east", "west"),
      ttb: ("north", "south"),
      btt: ("south", "north")
    ).at(repr(dir))

    for (i, step) in steps.enumerate() {
      let pos = if i == 0 {
        (0, 0)
      } else {
        (
          rel: adapt-offset((spacing, 0)),
          to: "arrow-" + str(i - 1) + ".end"
        )
      }

      let step-style = style.steps + step-style-at(i)
      
      let step-stroke = step-style.stroke
      let step-fill = step-style.fill
      let padding = resolve-number(ctx, step-style.padding)
      let radius = resolve-number(ctx, step-style.radius)
      let max-width = resolve-number(ctx, step-style.max-width)
      max-width -= 2 * padding

      let m = measure(step, width: max-width * ctx.length)
      let (w, h) = sizes.at(i)
      if equal-width {
        w = largest-width
      }
      if equal-height {
        h = highest-height
      }
      let step-name = "step-" + str(i)
      let tl = (
        rel: (
          ltr: (0, h / 2 + padding),
          rtl: (-w - padding * 2, h / 2 + padding),
          btt: (-w / 2 - padding, h + 2 * padding),
          ttb: (-w / 2 - padding, 0),
        ).at(repr(dir)),
        to: pos
      )
      let br = (
        rel: (w + padding * 2, -h - padding * 2),
        to: tl
      )

      draw.rect(
        tl, br,
        name: step-name,
        stroke: step-stroke,
        fill: step-fill,
        radius: radius
      )
      draw.content(
        step-name + ".center",
        box(
          width: w * ctx.length,
          align(center)[
            #set text(bottom-edge: "baseline")
            #step
          ]
        ),
        anchor: "center"
      )

      if i != steps.len() - 1 {
        let arrow-style = style.arrows + arrow-style-at(i)
        let arrow-stroke = arrow-style.stroke
        let arrow-fill = arrow-style.fill
        let arrow-w = resolve-number(ctx, arrow-style.width)
        let arrow-h = resolve-number(ctx, arrow-style.height)

        if arrow-fill == "steps" {
          let s1 = style.steps + step-style-at(i)
          let s2 = style.steps + step-style-at(i + 1)
          arrow-fill = gradient.linear(s1.fill, s2.fill).sample(50%)
        }

        let prev = "step-" + str(i)
        _draw-arrow(
          (
            rel: adapt-offset((spacing, 0)),
            to: prev + "." + anchor-2
          ),
          (
            rel: adapt-offset((spacing + arrow-w, 0)),
            to: prev + "." + anchor-2
          ),
          arrow-h,
          arrow-fill,
          arrow-stroke,
          name: "arrow-" + str(i)  
        )
      }
    }
  })
}

#let chevron(
  steps,
  step-style: palette.red,
  equal-length: false,
  dir: ltr,
  name: none,
  ..style
) = {
  draw.group(name: name, ctx => {
    draw.anchor("default", (0, 0))

    let style = styles.resolve(
      ctx.style,
      merge: style.named(),
      root: "process-chevron",
      base: process-chevron-default-style,
    )

    let spacing = resolve-number(ctx, style.spacing)

    let step-style-at = if type(step-style) == function {
      step-style
    } else if type(step-style) == array {
      i => {
        let s = step-style.at(calc.rem(i, step-style.len()))
        if type(s) == color or type(s) == gradient {
          (fill: s)
        } else {
          s
        }
      }
    } else if type(step-style) == gradient {
      i => (fill: step-style.sample(i / (steps.len() - 1) * 100%))
    }

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

    let vertical = dir in (ttb, btt)
    let reverse = dir in (rtl, ttb)
    let adapt-offset(offset, ..args) = {
      let offset = offset
      if vertical {
        if args.pos().len() != 0 {
          offset = args.pos().first()
        } else {
          offset = offset.rev()
        }
      }
      if reverse {
        offset = offset.map(v => -v)
      }
      return offset
    }

    let (anchor-1, anchor-2) = (
      ltr: ("west", "east"),
      rtl: ("east", "west"),
      ttb: ("north", "south"),
      btt: ("south", "north")
    ).at(repr(dir))

    for (i, step) in steps.enumerate() {
      let pos = if i == 0 {
        (0, 0)
      } else {
        (
          rel: adapt-offset((spacing, 0)),
          to: "step-" + str(i - 1) + ".end"
        )
      }

      let step-style = style.steps + step-style-at(i)
      
      let step-stroke = step-style.stroke
      let step-fill = step-style.fill
      let padding = resolve-number(ctx, step-style.padding)
      let max-width = resolve-number(ctx, step-style.max-width)
      max-width -= 2 * padding

      let m = measure(step, width: max-width * ctx.length)
      let (w, h) = sizes.at(i)
      if equal-length {
        if vertical {
          h = highest-height
        } else {
          w = largest-width
        }
      }
      let thickness = if vertical { largest-width } else { highest-height }
      let step-name = "step-" + str(i)
      let end = (
        rel: adapt-offset(
          (w + padding * 2, 0),
          (0, h + padding * 2)
        ),
        to: pos
      )

      /*draw.rect(
        tl, br,
        name: step-name,
        stroke: step-stroke,
        fill: step-fill
      )*/
      let cap-s = if i == 0 {
        style.start-cap
      } else {
        style.middle-cap
      }
      let cap-e = if i == steps.len() - 1 {
        style.end-cap
      } else {
        style.middle-cap
      }
      _draw-chevron(
        pos,
        end,
        thickness + padding * 2,
        step-fill,
        step-stroke,
        cap-s,
        cap-e,
        step-style.cap-ratio,
        i == 0 and style.start-in-cap,
        (i == steps.len() - 1) and style.end-in-cap,
        name: step-name
      )
      draw.content(
        step-name + ".center",
        box(
          width: w * ctx.length,
          align(center)[
            #set text(bottom-edge: "baseline")
            #step
          ]
        ),
        anchor: "center"
      )
    }
  })
}

#let bending(
  steps,
  arrow-style: auto,
  step-style: palette.red,
  equal-width: false,
  equal-height: false,
  name: none,
  ..style
) = {
  draw.group(name: name, ctx => {
    draw.anchor("default", (0, 0))

    let style = styles.resolve(
      ctx.style,
      merge: style.named(),
      root: "process-bending",
      base: process-bending-default-style,
    )

    let stride = style.layout.max-stride
    if stride == none {
      stride = steps.len()
    }
    let (flow-primary, flow-secondary) = style.layout.flow
    assert(
      flow-primary.axis() != flow-secondary.axis(),
      message: "Flow axes must be different"
    )
    let vertical-first = flow-primary.axis() == "vertical"
    let primary-reversed = false
    let secondary-reversed = false

    if vertical-first {
      primary-reversed = flow-primary == ttb
      secondary-reversed = flow-secondary == rtl
    } else {
      primary-reversed = flow-primary == rtl
      secondary-reversed = flow-secondary == ttb
    }

    let spacing = resolve-number(ctx, style.spacing)

    let step-style-at = if type(step-style) == function {
      step-style
    } else if type(step-style) == array {
      i => {
        let s = step-style.at(calc.rem(i, step-style.len()))
        if type(s) == color or type(s) == gradient {
          (fill: s)
        } else {
          s
        }
      }
    } else if type(step-style) == gradient {
      i => (fill: step-style.sample(i / (steps.len() - 1) * 100%))
    }

    let arrow-style-at = if type(arrow-style) == function {
      arrow-style
    } else if type(arrow-style) == array {
      i => {
        let s = arrow-style.at(calc.rem(i, arrow-style.len()))
        if type(s) == color or type(s) == gradient {
          (fill: s)
        } else {
          s
        }
      }
    } else if type(arrow-style) == gradient {
      i => (fill: arrow-style.sample(i / (steps.len() - 1) * 100%))
    } else {
      i => (:)
    }

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

    let get-step-dir(i) = {
      // If turning
      if calc.rem(i, stride) == 0 {
        return flow-secondary
      }
      
      // If "zag"
      if calc.odd(calc.div-euclid(i, stride)) {
        return flow-primary.inv()
      }
      
      // If "zig"
      return flow-primary
    }

    let get-offset(dir, spacing: spacing) = {
      return (
        ttb: (0, -1),
        btt: (0, 1),
        ltr: (1, 0),
        rtl: (-1, 0)
      ).at(repr(dir)).map(v => v * spacing)
    }

    for (i, step) in steps.enumerate() {
      let dir = get-step-dir(i)
      let pos = if i == 0 {
        (0, 0)
      } else {
        (
          rel: get-offset(dir),
          to: "arrow-" + str(i - 1) + ".end"
        )
      }

      let (anchor-1, anchor-2) = (
        ltr: ("west", "east"),
        rtl: ("east", "west"),
        ttb: ("north", "south"),
        btt: ("south", "north")
      ).at(repr(dir))

      let step-style = style.steps + step-style-at(i)
      
      let step-stroke = step-style.stroke
      let step-fill = step-style.fill
      let padding = resolve-number(ctx, step-style.padding)
      let radius = resolve-number(ctx, step-style.radius)
      let max-width = resolve-number(ctx, step-style.max-width)
      max-width -= 2 * padding

      let m = measure(step, width: max-width * ctx.length)
      let (w, h) = sizes.at(i)
      if equal-width {
        w = largest-width
      }
      if equal-height {
        h = highest-height
      }
      let step-name = "step-" + str(i)

      // Draw arrow
      if i != 0 {
        let arrow-style = style.arrows + arrow-style-at(i - 1)
        let arrow-stroke = arrow-style.stroke
        let arrow-fill = arrow-style.fill
        let arrow-w = resolve-number(ctx, arrow-style.width)
        let arrow-h = resolve-number(ctx, arrow-style.height)

        if arrow-fill == "steps" {
          let s1 = style.steps + step-style-at(i - 1)
          let s2 = style.steps + step-style-at(i)
          arrow-fill = gradient.linear(s1.fill, s2.fill).sample(50%)
        }

        let prev = "step-" + str(i - 1)
        _draw-arrow(
          (
            rel: get-offset(dir),
            to: prev + "." + anchor-2
          ),
          (
            rel: get-offset(dir, spacing: spacing + arrow-w),
            to: prev + "." + anchor-2
          ),
          arrow-h,
          arrow-fill,
          arrow-stroke,
          name: "arrow-" + str(i - 1)
        )
      }

      
      let tl = (
        rel: (
          ltr: (0, h / 2 + padding),
          rtl: (-w - padding * 2, h / 2 + padding),
          btt: (-w / 2 - padding, h + 2 * padding),
          ttb: (-w / 2 - padding, 0),
        ).at(repr(dir)),
        to: pos
      )
      let br = (
        rel: (w + padding * 2, -h - padding * 2),
        to: tl
      )

      draw.rect(
        tl, br,
        name: step-name,
        stroke: step-stroke,
        fill: step-fill,
        radius: radius
      )
      draw.content(
        step-name + ".center",
        box(
          width: w * ctx.length,
          align(center)[
            #set text(bottom-edge: "baseline")
            #step
          ]
        ),
        anchor: "center"
      )
    }
  })
}