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

/// Possible chevron caps: #cetz.chart.process.CHEVRON-CAPS
/// #example(```
/// for cap in chart.process.CHEVRON-CAPS {
///   chart.process.chevron(
///     ([Step 1], [Step 2]), spacing: 0,
///     start-cap: cap, middle-cap: cap, end-cap: cap)
///   translate(y: -1)
/// }
/// ```)
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

/// Draw a basic process chart, describing sequencial steps
///
/// #example(```
/// let steps = ([Improvise], [Adapt], [Overcome])
/// let colors = (red, orange, green).map(c => c.lighten(40%))
///
/// chart.process.basic(
///   steps,
///   step-style: colors,
///   equal-width: true,
///   steps: (max-width: 8em),
///   dir: ttb
/// )
/// ```)
///
/// = Styling
/// *Root* `process-basic` \
/// #show-parameter-block("spacing", ("number", "length"), [
///   Gap between steps and arrows.], default: 0.2em)
/// #show-parameter-block("steps.radius", ("number", "length"), [
///   Corner radius of the steps boxes.], default: 0.2em)
/// #show-parameter-block("steps.padding", ("number", "length"), [
///   Inner padding of the steps boxes.], default: 0.6em)
/// #show-parameter-block("steps.max-width", ("number", "length"), [
///   Maximum width of the steps boxes.], default: 5em)
/// #show-parameter-block("steps.fill", ("color", "gradient", "pattern", "none"), [
///   Fill color of the steps boxes.], default: none)
/// #show-parameter-block("steps.stroke", ("stroke", "none"), [
///   Stroke color of the steps boxes.], default: none)
/// #show-parameter-block("arrows.width", ("number", "length"), [
///   Width / length of arrows.], default: 1.2em)
/// #show-parameter-block("arrows.height", ("number", "length"), [
///   Height of arrows.], default: 1em)
/// #show-parameter-block("arrows.fill", ("string", "color", "gradient", "pattern", "none"), [
///   Fill color of the arrows. If set to "steps", the arrows will be filled with a color in between those of the neighboring steps.], default: "steps")
/// #show-parameter-block("arrows.stroke", ("stroke", "none"), [
///   Stroke used for the arrows.], default: none)
/// 
/// - steps (array): Array of steps (`<content>` or `<str>`)
/// - arrow-style (function, array, gradient): Arrow style of the following types:
///   - function: A function of the form `index => style` that must return a style dictionary.
///     This can be a `palette` function.
///   - array: An array of style dictionaries or fill colors of at least one item. For each arrow the style at the arrows
///     index modulo the arrays length gets used.
///   - gradient: A gradient that gets sampled for each data item using the arrows
///     index divided by the number of steps as position on the gradient.
///   If one of stroke or fill is not in the style dictionary, it is taken from the charts style.
/// - step-style (function, array, gradient): Step style of the following types:
///   - function: A function of the form `index => style` that must return a style dictionary.
///     This can be a `palette` function.
///   - array: An array of style dictionaries or fill colors of at least one item. For each step the style at the steps
///     index modulo the arrays length gets used.
///   - gradient: A gradient that gets sampled for each data item using the steps
///     index divided by the number of steps as position on the gradient.
///   If one of stroke or fill is not in the style dictionary, it is taken from the charts style.
/// - equal-width (boolean): If true, all steps will be sized to have the same width
/// - equal-height (boolean): If true, all steps will be sized to have the same height
/// - dir (direction): Direction in which the steps are laid out. The first step is always placed at (0, 0)
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

    let step-style-at = _get-style-at-func(step-style)
    let arrow-style-at = _get-style-at-func(arrow-style)

    let (
      sizes,
      largest-width,
      highest-height
    ) = _get-steps-sizes(steps, ctx, style, step-style-at)

    let vertical = dir.axis() == "vertical"
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

    let (anchor-1, anchor-2) = _dir-to-anchors(dir)

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
      let padding = resolve-number(ctx, step-style.padding)

      let (w, h) = sizes.at(i)
      if equal-width {
        w = largest-width
      }
      if equal-height {
        h = highest-height
      }
      let step-name = "step-" + str(i)

      _draw-step(ctx, step, pos, dir, step-style, step-name, w, h)

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


/// Draw a chevron process chart, describing sequencial steps
///
/// #example(```
/// let steps = ([Improvise], [Adapt], [Overcome])
/// let colors = (red, orange, green).map(c => c.lighten(40%))
///
/// chart.process.chevron(
///   steps,
///   step-style: colors,
///   equal-width: true,
///   steps: (max-width: 8em, cap-ratio: 25%),
///   dir: btt
/// )
/// ```)
///
/// = Styling
/// *Root* `process-chevron` \
/// #show-parameter-block("spacing", ("number", "length"), [
///   Gap between steps.], default: 0.2em)
/// #show-parameter-block("start-cap", ("string"), [
///   Cap at the start of the process (first step). See #link(label("CHEVRON-CAPS()"))[`CHEVRON-CAPS`] for possible values.], default: ">")
/// #show-parameter-block("mid-cap", ("string"), [
///   Cap between steps. See #link(label("CHEVRON-CAPS()"))[`CHEVRON-CAPS`] for possible values.], default: ">")
/// #show-parameter-block("end-cap", ("string"), [
///   Cap at the end of the process (last step). See #link(label("CHEVRON-CAPS()"))[`CHEVRON-CAPS`] for possible values.], default: ">")
/// #show-parameter-block("start-in-cap", ("boolean"), [
///   If true, the content of the first step is shifted inside the start cap (useful with "(" or "<").], default: false)
/// #show-parameter-block("end-in-cap", ("boolean"), [
///   If true, the content of the last step is shifted inside the end cap (useful with ")" or ">").], default: false)
/// #show-parameter-block("steps.padding", ("number", "length"), [
///   Inner padding of the steps boxes.], default: 0.6em)
/// #show-parameter-block("steps.max-width", ("number", "length"), [
///   Maximum width of the steps boxes.], default: 5em)
/// #show-parameter-block("steps.cap-ratio", ("ratio"), [
///   Ratio of the caps width relative to the steps heights (or the opposite if laid out vertically).], default: 50%)
/// #show-parameter-block("steps.fill", ("color", "gradient", "pattern", "none"), [
///   Fill color of the steps boxes.], default: none)
/// #show-parameter-block("steps.stroke", ("stroke", "none"), [
///   Stroke color of the steps boxes.], default: none)
/// 
/// - steps (array): Array of steps (`<content>` or `<str>`)
/// - step-style (function, array, gradient): Step style of the following types:
///   - function: A function of the form `index => style` that must return a style dictionary.
///     This can be a `palette` function.
///   - array: An array of style dictionaries or fill colors of at least one item. For each step the style at the steps
///     index modulo the arrays length gets used.
///   - gradient: A gradient that gets sampled for each data item using the steps
///     index divided by the number of steps as position on the gradient.
///   If one of stroke or fill is not in the style dictionary, it is taken from the charts style.
/// - equal-length (boolean): If true, all steps will be sized to have the same length (in the layout's direction, the other dimensions always being equal)
/// - dir (direction): Direction in which the steps are laid out. The first step is always placed at (0, 0)
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

    let step-style-at = _get-style-at-func(step-style)

    let (
      sizes,
      largest-width,
      highest-height
    ) = _get-steps-sizes(steps, ctx, style, step-style-at)

    let vertical = dir.axis() == "vertical"
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

    let (anchor-1, anchor-2) = _dir-to-anchors(dir)

    for (i, step) in steps.enumerate() {
      let step-style = style.steps + step-style-at(i)
      
      let step-stroke = step-style.stroke
      let step-fill = step-style.fill
      let padding = resolve-number(ctx, step-style.padding)

      let (w, h) = sizes.at(i)
      if equal-length {
        if vertical {
          h = highest-height
        } else {
          w = largest-width
        }
      }
      let thickness = if vertical { largest-width } else { highest-height }
      let cap-height = thickness + padding * 2
      let cap-width = step-style.cap-ratio / 100% * cap-height
      let step-name = "step-" + str(i)

      let cap-s = if i == 0 { style.start-cap }
                  else { style.middle-cap }
      let cap-e = if i == steps.len() - 1 { style.end-cap }
                  else { style.middle-cap }

      let pos = if i == 0 {
        (0, 0)
      } else {
        (
          rel: adapt-offset((
            spacing + if cap-s != "|" {cap-width} else {0},
            0
          )),
          to: "step-" + str(i - 1) + ".end"
        )
      }
      let end = (
        rel: adapt-offset(
          (w + padding * 2, 0),
          (0, h + padding * 2)
        ),
        to: pos
      )

      _draw-chevron(
        pos,
        end,
        cap-height,
        step-fill,
        step-stroke,
        cap-s,
        cap-e,
        step-style.cap-ratio,
        i == 0 and style.start-in-cap,
        (i == steps.len() - 1) and style.end-in-cap,
        name: step-name
      )
      _draw-step-content(step, step-name, w * ctx.length)
    }
  })
}

/// Draw a bending process chart, describing sequencial steps in a zigzag layout
///
/// #example(```
/// let steps = ([A], [B], [C], [D], [E], [F])
/// let colors = (
///   red, orange, yellow.mix(green), green, green.mix(blue), blue
/// ).map(c => c.lighten(40%))
///
/// chart.process.bending(
///   steps,
///   step-style: colors,
///   equal-width: true,
///   layout: (
///     flow: (ltr, btt), max-stride: 2
///   )
/// )
/// ```)
/// 
/// = Styling
/// *Root* `process-bending` \
/// #show-parameter-block("spacing", ("number", "length"), [
///   Gap between steps and arrows.], default: 0.2em)
/// #show-parameter-block("steps.radius", ("number", "length"), [
///   Corner radius of the steps boxes.], default: 0.2em)
/// #show-parameter-block("steps.padding", ("number", "length"), [
///   Inner padding of the steps boxes.], default: 0.6em)
/// #show-parameter-block("steps.max-width", ("number", "length"), [
///   Maximum width of the steps boxes.], default: 5em)
/// #show-parameter-block("steps.fill", ("color", "gradient", "pattern", "none"), [
///   Fill color of the steps boxes.], default: none)
/// #show-parameter-block("steps.stroke", ("stroke", "none"), [
///   Stroke color of the steps boxes.], default: none)
/// #show-parameter-block("arrows.width", ("number", "length"), [
///   Width / length of arrows.], default: 1.2em)
/// #show-parameter-block("arrows.height", ("number", "length"), [
///   Height of arrows.], default: 1em)
/// #show-parameter-block("layout.max-stride", ("number"), [
///   Maximum number of steps before turning, i.e. making a zigzag.], default: 3)
/// #show-parameter-block("layout.flow", ("array"), [
///   Pair of directions on different axes indicating the primary and secondary layout directions.], default: (ltr, ttb))
/// #show-parameter-block("arrows.fill", ("string", "color", "gradient", "pattern", "none"), [
///   Fill color of the arrows. If set to "steps", the arrows will be filled with a color in between those of the neighboring steps.], default: "steps")
/// #show-parameter-block("arrows.stroke", ("stroke", "none"), [
///   Stroke used for the arrows.], default: none)
/// 
/// - steps (array): Array of steps (`<content>` or `<str>`)
/// - arrow-style (function, array, gradient): Arrow style of the following types:
///   - function: A function of the form `index => style` that must return a style dictionary.
///     This can be a `palette` function.
///   - array: An array of style dictionaries or fill colors of at least one item. For each arrow the style at the arrows
///     index modulo the arrays length gets used.
///   - gradient: A gradient that gets sampled for each data item using the arrows
///     index divided by the number of steps as position on the gradient.
///   If one of stroke or fill is not in the style dictionary, it is taken from the charts style.
/// - step-style (function, array, gradient): Step style of the following types:
///   - function: A function of the form `index => style` that must return a style dictionary.
///     This can be a `palette` function.
///   - array: An array of style dictionaries or fill colors of at least one item. For each step the style at the steps
///     index modulo the arrays length gets used.
///   - gradient: A gradient that gets sampled for each data item using the steps
///     index divided by the number of steps as position on the gradient.
///   If one of stroke or fill is not in the style dictionary, it is taken from the charts style.
/// - equal-width (boolean): If true, all steps will be sized to have the same width
/// - equal-height (boolean): If true, all steps will be sized to have the same height
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

    let step-style-at = _get-style-at-func(step-style)
    let arrow-style-at = _get-style-at-func(arrow-style)

    let (
      sizes,
      largest-width,
      highest-height
    ) = _get-steps-sizes(steps, ctx, style, step-style-at)

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
      ).at(_dir-to-str(dir)).map(v => v * spacing)
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

      let (anchor-1, anchor-2) = _dir-to-anchors(dir)
      let step-style = style.steps + step-style-at(i)
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

      _draw-step(
        ctx, step, pos, dir, step-style, step-name, w, h
      )
    }
  })
}