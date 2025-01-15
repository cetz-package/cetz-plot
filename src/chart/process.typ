#import "/src/cetz.typ" as cetz: draw, styles, palette, coordinate, util.resolve-number, vector

#let default-style = (
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
#let process-basic-default-style = default-style

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
      base: default-style
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