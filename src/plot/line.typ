#import "/src/cetz.typ": canvas, draw

#import "util.typ"
#import "sample.typ"

// Transform points
//
// - data (array): Data points
// - line (str,dictionary): Line line
#let _transform-lines(data, line) = {
  let hvh-data(t) = {
    if type(t) == ratio {
      t = t / 1%
    }
    t = calc.max(0, calc.min(t, 1))

    let pts = ()

    let len = data.len()
    for i in range(0, len) {
      pts.push(data.at(i))

      if i < len - 1 {
        let (a, b) = (data.at(i), data.at(i+1))
        if t == 0 {
          pts.push((a.at(0), b.at(1)))
        } else if t == 1 {
          pts.push((b.at(0), a.at(1)))
        } else {
          let x = a.at(0) + (b.at(0) - a.at(0)) * t
          pts.push((x, a.at(1)))
          pts.push((x, b.at(1)))
        }
      }
    }
    return pts
  }

  if type(line) == str {
    line = (type: line)
  }

  let line-type = line.at("type", default: "raw")
  assert(line-type in ("raw", "linear", "spline", "vh", "hv", "hvh"))

  // Transform data into line-data
  let line-data = if line-type == "linear" {
    return util.linearized-data(data, line.at("epsilon", default: 0))
  } else if line-type == "spline" {
    return util.sampled-spline-data(data,
      line.at("tension", default: .5),
      line.at("samples", default: 15))
  } else if line-type == "vh" {
    return hvh-data(0)
  } else if line-type == "hv" {
    return hvh-data(1)
  } else if line-type == "hvh" {
    return hvh-data(line.at("mid", default: .5))
  } else {
    return data
  }
}

// Fill a plot by generating a fill path to y value `to`
#let _fill-segments-to(segments, to) = {
  for s in segments {
    let low  = calc.min(..s.map(v => v.at(0)))
    let high = calc.max(..s.map(v => v.at(0)))

    let origin = (low, to)
    let target = (high, to)

    draw.line(origin, ..s, target, stroke: none)
  }
}

// Fill a shape by generating a fill path for each segment
#let _fill-shape(paths) = {
  for p in paths {
    draw.line(..p, stroke: none)
  }
}

/// Add data to a plot environment.
///
/// Note: You can use this for scatter plots by setting
///       the stroke style to `none`: `add(..., style: (stroke: none))`.
///
/// Must be called from the body of a `plot(..)` command.
///
/// - domain (domain): Domain of `data`, if `data` is a function. Has no effect
///                    if `data` is not a function.
/// - hypograph (bool): Fill hypograph; uses the `hypograph` style key for
///                     drawing
/// - epigraph (bool): Fill epigraph; uses the `epigraph` style key for
///                    drawing
/// - fill (bool): Fill the shape of the plot
/// - fill-type (string): Fill type:
///   / `"axis"`: Fill the shape to y = 0
///   / `"shape"`: Fill the complete shape
/// - samples (int): Number of times the `data` function gets called for
///   sampling y-values. Only used if `data` is of type function. This parameter gets
///   passed onto `sample-fn`.
/// - sample-at (array): Array of x-values the function gets sampled at in addition
///   to the default sampling. This parameter gets passed to `sample-fn`.
/// - line (string, dictionary): Line type to use. The following types are
///   supported:
///   / `"raw"`: Plot raw data
///   / `"linear"`: Linearize data
///   / `"spline"`: Calculate a Catmull-Rom curve through all points
///   / `"vh"`: Move vertical and then horizontal
///   / `"hv"`: Move horizontal and then vertical
///   / `"hvh"`: Add a vertical step in the middle
///
///   If the value is a dictionary, the type must be
///   supplied via the `type` key. The following extra
///   attributes are supported:
///   / `"samples" <int>`: Samples of splines
///   / `"tension" <float>`: Tension of splines
///   / `"mid" <float>`: Mid-Point of hvh lines (0 to 1)
///   / `"epsilon" <float>`: Linearization slope epsilon for
///      use with `"linear"`, defaults to 0.
///
///   #example(```
///   let points(offset: 0) = ((0,0), (1,1), (2,0), (3,1), (4,0)).map(((x,y)) => {
///     (x,y + offset * 1.5)
///   })
///   plot.plot(size: (12, 3), axis-style: none, {
///     plot.add(points(offset: 5), line: (type: "hvh", mid: .1))
///     plot.add(points(offset: 4), line: "hvh")
///     plot.add(points(offset: 3), line: "hv")
///     plot.add(points(offset: 2), line: "vh")
///     plot.add(points(offset: 1), line: "spline")
///     plot.add(points(offset: 0), line: "linear")
///   })
///   ```, vertical: true)
///
/// - style (style): Style to use, can be used with a `palette` function
/// - axes (axes): Name of the axes to use for plotting. Reversing the axes
///   means rotating the plot by 90 degrees.
/// - mark (string): Mark symbol to place at each distinct value of the
///   graph. Uses the `mark` style key of `style` for drawing.
/// - mark-size (float): Mark size in cavas units
/// - data (array,function): Array of 2D data points (numeric) or a function
///   of the form `x => y`, where `x` is a value in `domain`
///   and `y` must be numeric or a 2D vector (for parametric functions).
///   #example(```
///   plot.plot(size: (2, 2), axis-style: none, {
///     // Using an array of points:
///     plot.add(((0,0), (calc.pi/2,1),
///                    (1.5*calc.pi,-1), (2*calc.pi,0)))
///     // Sampling a function:
///     plot.add(domain: (0, 2*calc.pi), calc.sin)
///   })
///   ```)
/// - label (none,content): Legend label to show for this plot.
#let add(domain: auto,
         hypograph: false,
         epigraph: false,
         fill: false,
         fill-type: "axis",
         style: (:),
         mark: none,
         mark-size: .2,
         mark-style: (:),
         samples: 50,
         sample-at: (),
         line: "raw",
         axes: ("x", "y"),
         label: none,
         data
         ) = {
  // If data is of type function, sample it
  if type(data) == function {
    data = sample.sample-fn(data, domain, samples, sample-at: sample-at)
  }

  // Transform data
  let line-data = _transform-lines(data, line)

  // Get x-domain
  let x-domain = (
    calc.min(..line-data.map(t => t.at(0))),
    calc.max(..line-data.map(t => t.at(0)))
  )

  // Get y-domain
  let y-domain = if line-data != none {(
    calc.min(..line-data.map(t => t.at(1))),
    calc.max(..line-data.map(t => t.at(1)))
  )}

  return ((
    priority: 0,
    fn: ptx => {
      ptx = util.set-auto-domain(ptx, axes, (x-domain, y-domain))

      ptx.data.push((
        label: label,
        axes: axes,
        fill: (ptx, proj) => {
          let (x, y) = axes.map(name => ptx.axes.at(name))

          if hypograph or epigraph or fill {
            let (min-y, max-y) = proj((0, y.min), (0, y.max)).map(v => v.at(1))
            let fill-paths = util.compute-fill-paths(line-data, (x, y))
              .map(path => proj(..path))
            if hypograph {
              _fill-segments-to(fill-paths, min-y)
            }
            if epigraph {
              _fill-segments-to(fill-paths, max-y)
            }
            if fill {
              if fill-type == "shape" {
                _fill-shape(fill-paths)
              } else {
                _fill-segments-to(fill-paths,
                  calc.max(calc.min(max-y, 0), min-y))
              }
            }
          }
        },
        stroke: (ptx, proj) => {
          let (x, y) = axes.map(name => ptx.axes.at(name))

          let stroke-paths = util.compute-stroke-paths(line-data, (x, y))
            .map(path => proj(..path))
          for path in stroke-paths {
            draw.line(..path, fill: none)
          }
        },
        preview: () => {
          // TODO
          draw.rect((0,0), (2,1.5))
        },
        style: style,
      ))

      return ptx
    }
  ),)
}

/// Add horizontal lines at one or more y-values. Every lines start and end points
/// are at their axis bounds.
///
/// #example(```
/// plot.plot(size: (2,2), x-tick-step: none, y-tick-step: none, {
///   plot.add(domain: (0, 4*calc.pi), calc.sin)
///   // Add 3 horizontal lines
///   plot.add-hline(-.5, 0, .5)
/// })
/// ```)
///
/// - ..y (float): Y axis value(s) to add a line at
/// - min (auto,float): X axis minimum value or auto to take the axis minimum
/// - max (auto,float): X axis maximum value or auto to take the axis maximum
/// - axes (array): Name of the axes to use for plotting
/// - style (style): Style to use, can be used with a palette function
/// - label (none,content): Legend label to show for this plot.
#let add-hline(..y,
               min: auto,
               max: auto,
               axes: ("x", "y"),
               style: (:),
               label: none,
               ) = {
  assert(y.pos().len() >= 1,
         message: "Specify at least one y value")
  assert(y.named().len() == 0)

  return ((
    priority: 0,
    fn: ptx => {
      let pts = y.pos()

      ptx.data.push((
        label: label,
        axes: axes,
        fill: (ptx, proj) => {
        },
        stroke: (ptx, proj) => {
          let (x, y) = axes.map(name => ptx.axes.at(name))

          let min = if min == auto { x.min } else { min }
          let max = if max == auto { x.max } else { max }
          for pt in pts.filter(v => y.min <= v and v <= y.max) {
            draw.line(..proj((min, pt), (max, pt)))
          }
        },
        preview: () => {
          // TODO
        },
        style: style,
      ))

      return ptx
    }
  ),)
}

/// Add vertical lines at one or more x-values. Every lines start and end points
/// are at their axis bounds.
///
/// #example(```
/// plot.plot(size: (2,2), x-tick-step: none, y-tick-step: none, {
///   plot.add(domain: (0, 2*calc.pi), calc.sin)
///   // Add 3 vertical lines
///   plot.add-vline(calc.pi/2, calc.pi, 3*calc.pi/2)
/// })
/// ```)
///
/// - ..x (float): X axis values to add a line at
/// - min (auto,float): Y axis minimum value or auto to take the axis minimum
/// - max (auto,float): Y axis maximum value or auto to take the axis maximum
/// - axes (array): Name of the axes to use for plotting, note that not all
///                 plot styles are able to display a custom axis!
/// - style (style): Style to use, can be used with a palette function
/// - label (none,content): Legend label to show for this plot.
#let add-vline(..x,
               min: auto,
               max: auto,
               axes: ("x", "y"),
               style: (:),
               label: none,
               ) = {
  assert(x.pos().len() >= 1,
         message: "Specify at least one x value")
  assert(x.named().len() == 0)

  return ((
    priority: 0,
    fn: ptx => {
      let pts = x.pos()

      ptx.data.push((
        label: label,
        axes: axes,
        fill: (ptx, proj) => {
        },
        stroke: (ptx, proj) => {
          let (x, y) = axes.map(name => ptx.axes.at(name))

          let min = if min == auto { y.min } else { min }
          let max = if max == auto { y.max } else { max }
          for pt in pts.filter(v => x.min <= v and v <= x.max) {
            draw.line(..proj((pt, min), (pt, max)))
          }
        },
        preview: () => {
          // TODO
        },
        style: style,
      ))

      return ptx
    }
  ),)
}

/// Fill the area between two graphs. This behaves same as `add` but takes
/// a pair of data instead of a single data array/function.
/// The area between both function plots gets filled. For a more detailed
/// explanation of the arguments, see @@add().
///
/// This can be used to display an error-band of a function.
///
/// #example(```
/// plot.plot(size: (2,2), x-tick-step: none, y-tick-step: none, {
///   plot.add-fill-between(domain: (0, 2*calc.pi),
///     calc.sin, // First function/data
///     calc.cos) // Second function/data
/// })
/// ```)
///
/// - domain (domain): Domain of both `data-a` and `data-b`. The domain is used for
///   sampling functions only and has no effect on data arrays.
/// - samples (int): Number of times the `data-a` and `data-b` function gets called for
///   sampling y-values. Only used if `data-a` or `data-b` is of
///   type function.
/// - sample-at (array): Array of x-values the function(s) get sampled at in addition
///   to the default sampling.
/// - line (string, dictionary): Line type to use, see @@add().
/// - style (style): Style to use, can be used with a palette function.
/// - label (none,content): Legend label to show for this plot.
/// - axes (array): Name of the axes to use for plotting.
/// - data-a (array,function): Data of the first plot, see @@add().
/// - data-b (array,function): Data of the second plot, see @@add().
#let add-fill-between(data-a,
                      data-b,
                      domain: auto,
                      samples: 50,
                      sample-at: (),
                      line: "raw",
                      axes: ("x", "y"),
                      label: none,
                      style: (:)) = {
  // If data is of type function, sample it
  if type(data-a) == function {
    data-a = sample.sample-fn(data-a, domain, samples, sample-at: sample-at)
  }
  if type(data-b) == function {
    data-b = sample.sample-fn(data-b, domain, samples, sample-at: sample-at)
  }

  // Transform data
  let line-a-data = _transform-lines(data-a, line)
  let line-b-data = _transform-lines(data-b, line)

  // Get x-domain
  let x-domain = (
    calc.min(..line-a-data.map(t => t.at(0)),
             ..line-b-data.map(t => t.at(0))),
    calc.max(..line-a-data.map(t => t.at(0)),
             ..line-b-data.map(t => t.at(0)))
  )

  // Get y-domain
  let y-domain = if line-a-data != none and line-b-data != none {(
    calc.min(..line-a-data.map(t => t.at(1)),
             ..line-b-data.map(t => t.at(1))),
    calc.max(..line-a-data.map(t => t.at(1)),
             ..line-b-data.map(t => t.at(1)))
  )}

  let prepare(self, ctx) = {
    // Generate stroke paths
    self.stroke-paths = (
      a: util.compute-stroke-paths(self.line-data.a, ctx.axes),
      b: util.compute-stroke-paths(self.line-data.b, ctx.axes),
    )

    // Generate fill paths
    self.fill-paths = util.compute-fill-paths(self.line-data.a + self.line-data.b.rev(), ctx.axes)

    return self
  }

  let stroke(self, ctx) = {
    for p in self.stroke-paths.a {
      draw.line(..p, fill: none)
    }
    for p in self.stroke-paths.b {
      draw.line(..p, fill: none)
    }
  }

  let fill(self, ctx) = {
    _fill-shape(self.fill-paths)
  }

  ((
    type: "fill-between",
    label: label,
    axes: axes,
    line-data: (a: line-a-data, b: line-b-data),
    x-domain: x-domain,
    y-domain: y-domain,
    style: style,
    plot-prepare: prepare,
    plot-stroke: stroke,
    plot-fill: fill,
    plot-legend-preview: self => {
      draw.rect((0,0), (1,1), ..self.style)
    }
  ),)
}
