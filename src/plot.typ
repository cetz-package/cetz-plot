#import "/src/cetz.typ"
#import cetz: util, draw, matrix, vector, styles, palette, coordinate, styles
#import util: bezier

#import "/src/axis.typ"
#import "/src/projection.typ"
#import "/src/spine.typ"
#import "/src/ticks.typ"
#import "/src/sub-plot.typ"
#import "/src/compat.typ"

#import "/src/plot/sample.typ": sample-fn, sample-fn2
#import "/src/plot/line.typ": add, add-hline, add-vline, add-fill-between
#import "/src/plot/contour.typ": add-contour
#import "/src/plot/boxwhisker.typ": add-boxwhisker
#import "/src/plot/util.typ" as plot-util
#import "/src/plot/legend.typ" as plot-legend
#import "/src/plot/annotation.typ": annotate, calc-annotation-domain
#import "/src/plot/bar.typ": add-bar
#import "/src/plot/errorbar.typ": add-errorbar
#import "/src/plot/mark.typ"
#import "/src/plot/comb.typ": add-comb
#import "/src/plot/violin.typ": add-violin
#import "/src/plot/formats.typ"
#import plot-legend: add-legend

#let default-colors = (blue, red, green, yellow, black)

#let default-plot-style(i) = {
  let color = default-colors.at(calc.rem(i, default-colors.len()))
  return (stroke: color,
          fill: color.lighten(75%))
}

#let default-mark-style(i) = {
  return default-plot-style(i)
}

/// Add a linear axis to a plot
/// - name (str): Axis name
/// - min: (none, float): Minimum
/// - max: (none, float): Maximum
#let lin-axis(name, min: none, max: none, ..options) = {
  ((priority: -100, fn: (ptx) => {
    ptx.axes.insert(name, axis.linear(name, min, max, ..options))
    return ptx
  }),)
}

/// Add a logarithmic axis to a plot
/// - name (str): Axis name
/// - min: (none, float): Minimum
/// - max: (none, float): Maximum
/// - base: (int): Log base
#let log-axis(name, min: none, max: none, base: 10, ..options) = {
  ((priority: -100, fn: (ptx) => {
    ptx.axes.insert(name, axis.logarithmic(name, min, max, base, ..options))
    return ptx
  }),)
}


#let templates = (
  scientific: (ptx) => {
    lin-axis("x")
    lin-axis("y")
    lin-axis("u")
    lin-axis("v")
    sub-plot.new("x", "y", "u", "v")
  },
  school-book: (ptx) => {
    lin-axis("x")
    lin-axis("y")
    sub-plot.new("x", "y")
  },
)

/// Create a plot environment. Data to be plotted is given by passing it to the
/// `plot.add` or other plotting functions. The plot environment supports different
/// axis styles to draw, see its parameter `axis-style:`.
///
/// #example(```
/// plot.plot(size: (2,2), x-tick-step: none, y-tick-step: none, {
///   plot.add(((0,0), (1,1), (2,.5), (4,3)))
/// })
/// ```)
///
/// To draw elements insides a plot, using the plots coordinate system, use
/// the `plot.annotate(..)` function.
///
/// = parameters
///
/// = Options
///
/// You can use the following options to customize each axis of the plot. You must pass them as named arguments prefixed by the axis name followed by a dash (`-`) they should target. Example: `x-min: 0`, `y-ticks: (..)` or `x2-label: [..]`.
///
/// #show-parameter-block("label", ("none", "content"), default: "none", [
///   The axis' label. If and where the label is drawn depends on the `axis-style`.])
/// #show-parameter-block("min", ("auto", "float"), default: "auto", [
///   Axis lower domain value. If this is set greater than than `max`, the axis' direction is swapped])
/// #show-parameter-block("max", ("auto", "float"), default: "auto", [
///   Axis upper domain value. If this is set to a lower value than `min`, the axis' direction is swapped])
/// #show-parameter-block("equal", ("string"), default: "none", [
///   Set the axis domain to keep a fixed aspect ratio by multiplying the other axis domain by the plots aspect ratio.
///   This can be useful to force one axis to grow or shrink with another one.
///   You can only "lock" two axes of different orientations.
///   #example(```
///   plot.plot(size: (2,1), x-tick-step: 1, y-tick-step: 1,
///             x-equal: "y",
///   {
///     plot.add(domain: (0, 2 * calc.pi),
///       t => (calc.cos(t), calc.sin(t)))
///   })
///   ```)
/// ])
/// #show-parameter-block("tick-step", ("none", "auto", "float"), default: "auto", [
///   The increment between tick marks on the axis. If set to `auto`, an
///   increment is determined. When set to `none`, incrementing tick marks are disabled.])
/// #show-parameter-block("minor-tick-step", ("none", "float"), default: "none", [
///   Like `tick-step`, but for minor tick marks. In contrast to ticks, minor ticks do not have labels.])
/// #show-parameter-block("ticks", ("none", "array"), default: "none", [
///   A List of custom tick marks to additionally draw along the axis. They can be passed as
///   an array of `<float>` values or an array of `(<float>, <content>)` tuples for
///   setting custom tick mark labels per mark.
///
///   #example(```
///   plot.plot(x-tick-step: none, y-tick-step: none,
///             x-min: 0, x-max: 4,
///             x-ticks: (1, 2, 3),
///             y-min: 1, y-max: 2,
///             y-ticks: ((1, [One]), (2, [Two])),
///   {
///     plot.add(((0,0),))
///   })
///   ```)
///
///   Examples: `(1, 2, 3)` or `((1, [One]), (2, [Two]), (3, [Three]))`])
/// #show-parameter-block("format", ("none", "string", "function"), default: "float", [
///   How to format the tick label: You can give a function that takes a `<float>` and return
///   `<content>` to use as the tick label. You can also give one of the predefined options:
///   / float: Floating point formatting rounded to two digits after the point (see `decimals`)
///   / sci: Scientific formatting with $times 10^n$ used as exponet syntax
///
///   #example(```
///   let formatter(v) = if v != 0 {$ #{v/calc.pi} pi $} else {$ 0 $}
///   plot.plot(x-tick-step: calc.pi, y-tick-step: none,
///             x-min: 0, x-max: 2 * calc.pi,
///             x-format: formatter,
///   {
///     plot.add(((0,0),))
///   })
///   ```)
/// ])
/// #show-parameter-block("decimals", ("int"), default: "2", [
///   Number of decimals digits to display for tick labels, if the format is set
///   to `"float"`.
/// ])
/// #show-parameter-block("mode", ("none", "string"), default: "none", [
///   The scaling function of the axis. Takes `lin` (default) for linear scaling,
///   and `log` for logarithmic scaling.])
/// #show-parameter-block("base", ("none", "number"), default: "none", [
///   The base to be used when labeling axis ticks in logarithmic scaling])
/// #show-parameter-block("grid", ("bool", "string"), default: "false", [
///   If `true` or `"major"`, show grid lines for all major ticks. If set
///   to `"minor"`, show grid lines for minor ticks only.
///   The value `"both"` enables grid lines for both, major- and minor ticks.
///
///   #example(```
///   plot.plot(x-tick-step: 1, y-tick-step: 1,
///             y-minor-tick-step: .2,
///             x-min: 0, x-max: 2, x-grid: true,
///             y-min: 0, y-max: 2, y-grid: "both", {
///     plot.add(((0,0),))
///   })
///   ```)
/// ])
/// #show-parameter-block("break", ("bool"), default: "false", [
///   If true, add a "sawtooth" at the start or end of the axis line, depending
///   on the axis bounds. If the axis min. value is > 0, a sawtooth is added
///   to the start of the axes, if the axis max. value is < 0, a sawtooth is added
///   to its end.])
///
/// - body (body): Calls of `plot.add` or `plot.add-*` commands. Note that normal drawing
///   commands like `line` or `rect` are not allowed inside the plots body, instead wrap
///   them in `plot.annotate`, which lets you select the axes used for drawing.
/// - size (array): Plot size tuple of `(<width>, <height>)` in canvas units.
///   This is the plots inner plotting size without axes and labels.
/// - axis-style (none, string): How the axes should be styled:
///   / scientific: Frames plot area using a rectangle and draw axes `x` (bottom), `y` (left), `x2` (top), and `y2` (right) around it.
///     If `x2` or `y2` are unset, they mirror their opposing axis.
///   / scientific-auto: Draw set (used) axes `x` (bottom), `y` (left), `x2` (top) and `y2` (right) around
///     the plotting area, forming a rect if all axes are in use or a L-shape if only `x` and `y` are in use.
///   / school-book: Draw axes `x` (horizontal) and `y` (vertical) as arrows pointing to the right/top with both crossing at $(0, 0)$
///   / left: Draw axes `x` and `y` as arrows, while the y axis stays on the left (at `x.min`)
///               and the x axis at the bottom (at `y.min`)
///   / `none`: Draw no axes (and no ticks).
///
///   #example(```
///   let opts = (x-tick-step: none, y-tick-step: none, size: (2,1))
///   let data = plot.add(((-1,-1), (1,1),), mark: "o")
///
///   for name in (none, "school-book", "left", "scientific") {
///     plot.plot(axis-style: name, ..opts, data, name: "plot")
///     content(((0,-1), "-|", "plot.south"), repr(name))
///     set-origin((3.5,0))
///   }
///   ```, vertical: true)
/// - plot-style (style,function): Styling to use for drawing plot graphs.
///   This style gets inherited by all plots and supports `palette` functions.
///   The following style keys are supported:
///   #show-parameter-block("stroke", ("none", "stroke"), default: 1pt, [
///     Stroke style to use for stroking the graph.
///   ])
///   #show-parameter-block("fill", ("none", "paint"), default: none, [
///     Paint to use for filled graphs. Note that not all graphs may support filling and
///     that you may have to enable filling per graph, see `plot.add(fill: ..)`.
///   ])
/// - mark-style (style,function): Styling to use for drawing plot marks.
///   This style gets inherited by all plots and supports `palette` functions.
///   The following style keys are supported:
///   #show-parameter-block("stroke", ("none", "stroke"), default: 1pt, [
///     Stroke style to use for stroking the mark.
///   ])
///   #show-parameter-block("fill", ("none", "paint"), default: none, [
///     Paint to use for filling marks.
///   ])
/// - fill-below (bool): If true, the filled shape of plots is drawn _below_ axes.
/// - name (string): The plots element name to be used when referring to anchors
/// - legend (none, auto, coordinate): The position the legend will be drawn at. See plot-legends for information about legends. If set to `<auto>`, the legend's "default-placement" styling will be used. If set to a `<coordinate>`, it will be taken as relative to the plot's origin.
/// - legend-anchor (auto, string): Anchor of the legend group to use as its origin.
///   If set to `auto` and `lengend` is one of the predefined legend anchors, the
///   opposite anchor to `legend` gets used.
/// - legend-style (style): Style key-value overwrites for the legend style with style root `legend`.
/// - ..options (any): Axis options, see _options_ below.
#let plot(body,
          name: none,
          size: (5, 4),
          template: "scientific",
          plot-style: default-plot-style,
          legend: auto,
          draw-legend: plot-legend.draw-legend,
          legend-style: (:),
          fill-below: true,
          ..options) = draw.get-ctx(ctx => {
  let body = body
  let ptx = (
    cetz-ctx: ctx,

    default-size: size,
    options: options.named(),

    axes: (:),   // Shared axes
    plots: (),   // Sub plots
    data: (),    // Plot data
    legend: (),  // Legend entries
    anchors: (), // Anchors
  )

  if template != none and template in templates {
    body = (templates.at(template))(ptx) + body
  }

  // Wrap old style elements
  body = body.map(elem => {
    return if "type" in elem {
      compat.wrap(elem)
    } else {
      elem
    }
  })

  let plot-elements = body
    .filter(elem => type(elem) == dictionary)
    .sorted(key: elem => elem.at("priority", default: 0))
  let cetz-elements = body
    .filter(elem => type(elem) == function)

  for elem in plot-elements.filter(elem => elem.priority <= 0) {
    assert("fn" in elem,
      message: "Invalid plot element: " + repr(elem))

    ptx = (elem.fn)(ptx)
    assert(ptx != none)
  }

  // Apply axis options & prepare axes
  ptx = plot-util.setup-axes(ptx, options.named())

  for elem in plot-elements.filter(elem => elem.priority > 0) {
    assert("fn" in elem,
      message: "Invalid plot element: " + repr(elem))

    ptx = (elem.fn)(ptx)
    assert(ptx != none)
  }

  // Prepare styles
  ptx.data = ptx.data.enumerate().map(((i, data)) => {
    let style = if type(plot-style) == function {
      (plot-style)(i)
    } else if type(plot-style) == array {
      plot-style.at(i)
    } else {
      plot-style
    }

    data.style = cetz.util.merge-dictionary(style, data.at("style", default: (:)))
    return data
  })

  draw.group(name: name, {
    draw.group(name: "plot", {
      for sub-plot in ptx.plots {
        let matching-data = ()
        for proj in sub-plot.projections {
          let axis-names = proj.axes.map(ax => ax.name)
          let sub-data = ptx.data.filter(data => data.axes.all(ax => ax in axis-names))
          if sub-data != () {
            matching-data.push((proj, sub-data))
          }
        }

        // Draw background
        for (proj, sub-data) in matching-data {
          for data in sub-data {
            draw.scope({
              draw.set-style(..data.style)
              if fill-below {
                (data.fill)(ptx, proj.transform)
              }
            })
          }
        }

        // Draw spine (axes, ticks, ...)
        if sub-plot.at("spine", default: none) != none {
          draw.group(name: sub-plot.spine.name, {
            (sub-plot.spine.draw)(ptx)
          })
        }

        // Draw foreground
        for (proj, sub-data) in matching-data {
          for data in sub-data {
            draw.scope({
              draw.set-style(..data.style)
              if not fill-below {
                (data.fill)(ptx, proj.transform)
              }
              (data.stroke)(ptx, proj.transform)
            })
          }
        }
      }

      draw.scope({
        cetz-elements
      })
    })

    if ptx.legend != none {
      draw.scope({
      /*
        draw.set-origin("plot." + options.at("legend", default: "north-east"))
        draw.group(name: "legend", anchor: options.at("legend-anchor", default: "north-west"), {
          draw.anchor("default", (0,0))
          draw-legend(ptx)
        })
      */
      })
    }

    for (name, pt) in ptx.anchors {
      draw.anchor(name, pt)
    }

    draw.copy-anchors("plot")
  })
})

/// Add an anchor to a plot environment
///
/// This function is similar to `draw.anchor` but it takes an additional
/// axis tuple to specify which axis coordinate system to use.
///
/// #example(```
/// plot.plot(size: (2,2), name: "plot",
///           x-tick-step: none, y-tick-step: none, {
///   plot.add(((0,0), (1,1), (2,.5), (4,3)))
///   plot.add-anchor("pt", (1,1))
/// })
///
/// line("plot.pt", ((), "|-", (0,1.5)), mark: (start: ">"), name: "line")
/// content("line.end", [Here], anchor: "south", padding: .1)
/// ```)
///
/// - name (string): Anchor name
/// - position (tuple): Tuple of x and y values.
///   Both values can have the special values "min" and
///   "max", which resolve to the axis min/max value.
///   Position is in axis space defined by the axes passed to `axes`.
/// - axes (tuple): Name of the axes to use `("x", "y")` as coordinate
///   system for `position`. Note that both axes must be used,
///   as `add-anchors` does not create them on demand.
#let add-anchor(name, position, axes: ("x", "y")) = {
  ((
    priority: 100,
    fn: ptx => {
      for plot in ptx.plots {
        for proj in plot.projections {
          if axes.all(name => proj.axes.contains(name)) {
            // FIXME: Broken
            let pt = (proj.transform)(position).first()
            ptx.anchors.push((name, pt))
          }
        }
      }
      return ptx
    }
  ),)
}
