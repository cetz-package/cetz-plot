#import "/src/cetz.typ": draw, util, styles

#import "plot/legend.typ" as plot-legend
#import "plot/axis-style.typ"
#import "axes/axes.typ"


// TODO: Refactor this into a better way of providing palettes

#let default-colors = (
  rgb("#1982c4"),
  rgb("#ff595e"), 
  rgb("#ffca3a"), 
  rgb("#8ac926"), 
  rgb("#6a4c93")
)

#let default-plot-style(i) = {
  let color = default-colors.at(calc.rem(i, default-colors.len()))
  return (
    stroke: color,
    fill: color.transparentize(80%)
  )
}

#let default-mark-style(i) = {
  return default-plot-style(i)
}

// Get the default axis orientation
// depending on the axis name
#let get-default-axis-horizontal(name) = {
  return lower(name).starts-with("x")
}

// Consider splitting into sevaral files
#let _handle-named-axis-args(ctx, axis-dict, options, plot-size) = {

  // Get axis option for name
  let get-axis-option(axis-name, name, default) = {
    let v = options.at(axis-name + "-" + name, default: default)
    if v == auto { default } else { v }
  }

  for (name, axis) in axis-dict {
    if not "ticks" in axis { axis.ticks = () }
    axis.label = get-axis-option(name, "label", $#name$)

    // Configure axis bounds
    axis.min = get-axis-option(name, "min", axis.min)
    axis.max = get-axis-option(name, "max", axis.max)

    assert(axis.min not in (none, auto) and
           axis.max not in (none, auto),
      message: "Axis min and max must be set.")
    if axis.min == axis.max {
      axis.min -= 1; axis.max += 1
    }

    axis.mode = get-axis-option(name, "mode", "lin")
    axis.base = get-axis-option(name, "base", 10)

    // Configure axis orientation
    axis.horizontal = get-axis-option(name, "horizontal",
      get-default-axis-horizontal(name))

    // Configure ticks
    axis.ticks.list = get-axis-option(name, "ticks", ())
    axis.ticks.step = get-axis-option(name, "tick-step", axis.ticks.step)
    axis.ticks.minor-step = get-axis-option(name, "minor-tick-step", axis.ticks.minor-step)
    axis.ticks.decimals = get-axis-option(name, "decimals", 2)
    axis.ticks.unit = get-axis-option(name, "unit", [])
    axis.ticks.format = get-axis-option(name, "format", axis.ticks.format)

    // Axis break
    axis.show-break = get-axis-option(name, "break", false)
    axis.inset = get-axis-option(name, "inset", (0, 0))

    // Configure grid
    axis.ticks.grid = get-axis-option(name, "grid", false)

    axis-dict.at(name) = axis
  }

  // Set axis options round two, after setting
  // axis bounds
  for (name, axis) in axis-dict {
    let changed = false

    // Configure axis aspect ratio
    let equal-to = get-axis-option(name, "equal", none)
    if equal-to != none {
      assert.eq(type(equal-to), str,
        message: "Expected axis name.")
      assert(equal-to != name,
        message: "Axis can not be equal to itself.")

      let other = axis-dict.at(equal-to, default: none)
      assert(other != none,
        message: "Other axis must exist.")
      assert(other.horizontal != axis.horizontal,
        message: "Equal axes must have opposing orientation.")

      let (w, h) = plot-size
      let ratio = if other.horizontal {
        h / w
      } else {
        w / h
      }
      axis.min = other.min * ratio
      axis.max = other.max * ratio

      changed = true
    }

    if changed {
      axis-dict.at(name) = axis
    }
  }

  for (name, axis) in axis-dict {
    axis-dict.at(name) = axes.prepare-axis(ctx, axis, name)
  }

  return axis-dict
}

#let _create-axis-dict(ctx, data, annotations, anchors, options, size) = {
  let axis-dict = (:)
  for d in data + annotations {
    if "axes" not in d { continue }

    for (i, name) in d.axes.enumerate() {
      if not name in axis-dict {
        axis-dict.insert(name, axes.axis(
          min: none, max: none))
      }

      let axis = axis-dict.at(name)
      let domain = if i == 0 {
        d.at("x-domain", default: (0, 0))
      } else {
        d.at("y-domain", default: (0, 0))
      }
      if domain != (none, none) {
        axis.min = util.min(axis.min, ..domain)
        axis.max = util.max(axis.max, ..domain)
      }

      axis-dict.at(name) = axis
    }
  }

  // Create axes for anchors
  for a in anchors {
    for (i, name) in a.axes.enumerate() {
      if not name in axis-dict {
        axis-dict.insert(name, axes.axis(min: none, max: none))
      }
    }
  }

  // Adjust axis bounds for annotations
  for a in annotations {
    let (x, y) = a.axes.map(name => axis-dict.at(name))
    (x, y) = calc-annotation-domain(ctx, x, y, a)
    axis-dict.at(a.axes.at(0)) = x
    axis-dict.at(a.axes.at(1)) = y
  }

  // Set axis options
  axis-dict = _handle-named-axis-args(ctx, axis-dict, options.named(), size)
  return axis-dict
}

#let _destructure-body(body) = {

  // early exit
  if body == none {return ((),(),())}

  let data = ()
  let anchors = ()
  let annotations = ()
  for cmd in body {
    assert(type(cmd) == dictionary and "type" in cmd,
           message: "Expected plot sub-command in plot body")

    if cmd.type == "anchor" {
      anchors.push(cmd)
    } else if cmd.type == "annotation" {
      annotations.push(cmd)
    } else { 
      data.push(cmd) 
    }
  }

  return (data, anchors, annotations)
}

#let _prepare-data-styles(data, plot-style, mark-style) = {
  for i in range(data.len()) {
    if "style" not in data.at(i) { continue }

    let style-base = plot-style
    if type(style-base) == function {
      style-base = (style-base)(i)
    }
    assert.eq(type(style-base), dictionary,
      message: "plot-style must be of type dictionary")

    if type(data.at(i).style) == function {
      data.at(i).style = (data.at(i).style)(i)
    }
    assert.eq(type(style-base), dictionary,
      message: "data plot-style must be of type dictionary")

    data.at(i).style = util.merge-dictionary(
      style-base, data.at(i).style)

    if "mark-style" in data.at(i) {
      let mark-style-base = mark-style
      if type(mark-style-base) == function {
        mark-style-base = (mark-style-base)(i)
      }
      assert.eq(type(mark-style-base), dictionary,
        message: "mark-style must be of type dictionary")

      if type(data.at(i).mark-style) == function {
        data.at(i).mark-style = (data.at(i).mark-style)(i)
      }

      if type(data.at(i).mark-style) == dictionary {
        data.at(i).mark-style = util.merge-dictionary(
          mark-style-base,
          data.at(i).mark-style
        )
      }
    }
  }
  return data
}

#let plot(
  body,
  size: (1,1),
  axis-style: axis-style.orthorect-2d,
  name: none,
  plot-style: default-plot-style,
  mark-style: default-mark-style,
  legend: auto,
  legend-anchor: auto,
  legend-style: (:),
  ..options
) = draw.group(name: name, ctx => {

  // TODO: Assert cetz min version here!

  let (data, anchors, annotations) = _destructure-body(body)
  let axis-dict = _create-axis-dict(ctx, data, anchors, annotations, options, size)
  data = _prepare-data-styles(data, plot-style, mark-style)

  draw.group(name: "plot", {
    draw.anchor("origin", (0, 0))

    // Prepare
    for i in range(data.len()) {
      if "axes" not in data.at(i) { continue }

      let axes = data.at(i).axes.map(name => axis-dict.at(name))
      let plot-ctx = axis-style.make-ctx(axes, size)

      if "plot-prepare" in data.at(i) {
        data.at(i) = (data.at(i).plot-prepare)(data.at(i), plot-ctx)
        assert(data.at(i) != none,
          message: "Plot prepare(self, cxt) returned none!")
      }
    }

    // Background Annotations
    for a in annotations.filter(a => a.background) {
      let axes = a.axes.map(name => axis-dict.at(name))
      let plot-ctx = axis-style.make-ctx(axes, size)

      axis-style.data-viewport(axes, size, {
        draw.anchor("default", (0, 0))
        a.body
      })
    }

    // Fill
    for d in data {
      if "axes" not in d { continue }

      let axes = d.axes.map(name => axis-dict.at(name))
      let plot-ctx = axis-style.make-ctx(axes, size)

      axis-style.data-viewport(axes, size, {
        draw.anchor("default", (0, 0))
        draw.set-style(..d.style)

        if "plot-fill" in d {
          (d.plot-fill)(d, plot-ctx)
        }
      })
    }

    axis-style.draw-axes(size, axis-dict)

    // Stroke + Mark data
    for d in data {
      if "axes" not in d { continue }

      let axes = d.axes.map(name => axis-dict.at(name))
      let plot-ctx = axis-style.make-ctx(axes, size)

      axis-style.data-viewport(axes, size, {
        draw.anchor("default", (0, 0))
        draw.set-style(..d.style)

        if "plot-stroke" in d {
          (d.plot-stroke)(d, plot-ctx)
        }
      })

      if "mark" in d and d.mark != none {
        draw.group({
          draw.set-style(..d.style, ..d.mark-style)
          mark.draw-mark(d.data, x, y, d.mark, d.mark-size, size)
        })
      }
    }

    // Foreground Annotations
    for a in annotations.filter(a => not a.background) {
      let axes = a.axes.map(name => axis-dict.at(name))
      let plot-ctx = make-ctx(axes, size)

      data-viewport(axes, size, {
        draw.anchor("default", (0, 0))
        a.body
      })
    }

    // Place anchors
    for a in anchors {
      let axes = a.axes.map(name => axis-dict.at(name))
      let plot-ctx = make-ctx(axes, size)

      let pt = a.position.enumerate().map(((i, v)) => {
        if v == "min" { return axis-dict.at(a.axes.at(i)).min }
        if v == "max" { return axis-dict.at(a.axes.at(i)).max }
        return v
      })
      pt = axes.transform-vec(size, x, y, none, pt)
      if pt != none {
        draw.anchor(a.name, pt)
      }
    }
  })

  if legend != none {

    let items = data.filter(d => "label" in d and d.label != none)
    if items.len() > 0 {

      let legend-style = styles.resolve(
        ctx.style,
        base: plot-legend.default-style, 
        merge: legend-style,
         root: "legend"
      )
        
      plot-legend.add-legend-anchors(legend-style, "plot", size)

      plot-legend.legend(legend, anchor: legend-anchor, {
        for item in items {
          let preview = if "plot-legend-preview" in item {
            _ => {(item.plot-legend-preview)(item) }
          } else {
            auto
          }

          plot-legend.item(
            item.label,
            preview,
            mark: item.at("mark", default: none),
            mark-size: item.at("mark-size", default: none),
            mark-style: item.at("mark-style", default: none),
            ..item.at("style", default: (:))
          )
        }
      }, ..legend-style)

    }
  }

})