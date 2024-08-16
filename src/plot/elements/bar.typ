#import "/src/cetz.typ": draw

// TODO: Refactor stroke-paths and fill-paths generation into something more
// optimized

#let _prepare(self, ctx) = {

  self.stroke-paths = self.bar-data.map(d=>{

    let (x,y) = (d.at(self.x-key),d.at(self.y-key))
    let offset = if self.y-offset-key != none {
      d.at(self.y-offset-key, default: 0)
    } else {
      0
    };

    (ctx.compute-stroke-paths)(
      (
        (x - self.bar-width/2, offset),
        (x - self.bar-width/2, y+offset),
        (x + self.bar-width/2, y+offset),
        (x + self.bar-width/2, offset),
      ), 
      ctx,
    )
  })

  self.fill-paths = self.bar-data.map(d=>{
    let (x,y) = (d.at(self.x-key),d.at(self.y-key))
    let offset = if self.y-offset-key != none {
      d.at(self.y-offset-key, default: 0)
    } else {
      0
    };

    (ctx.compute-fill-paths)(
      (
        (x - self.bar-width/2, offset),
        (x - self.bar-width/2, y+offset),
        (x + self.bar-width/2, y+offset),
        (x + self.bar-width/2, offset),
      ), 
      ctx,
    )
  })

  return self
}

#let _stroke(self, ctx) = {
  for rects in self.stroke-paths {
    for p in rects {
      draw.line(..p, ..self.style, fill: none)
    }
  }
}

#let _fill(self, ctx) = {
  for d in self.fill-paths {
    for p in d {
      draw.line(..p, ..self.style, stroke: none)
    }
  }
}

#let _legend-preview(self) = {
  draw.rect((0,0), (1,0.5), ..self.style)
}

/// Adds a series of bars. Bars are of `bar-width` total width, centered at
/// a given `x` coordinate, between heights `y-offset` (default: `0`) and `y-offset`
/// \+ `y`.
///
/// ```example
/// cetz-plot.plot(
///   x-min: -0.5, x-max: 0.5, x-tick-step: 0.25,
///   y-max: 1.2,
///  {
///   cetz-plot.add.bar(
///     ((0,1),),
///     bar-width: 0.5,
///   )
/// })
/// ```
///
/// - data (array): An array representing a single series of bars. Entries can be
///   of type `array` or `dictionary`, and must contain within them an `x` coordinate,
///   and optionally a `y` coordinate expressing the magnitude of the bar to add, and
///   optionally a `y-offset` coordinate (default: 0) which dictates where the bar's base
///   is draw.
/// - x-key (string, int): The key at which the `x` coordinate is described in each `data`
///   entry.
/// - y-key (string, int): The key at which the `y` coordinate is described in each `data`
///   entry.
/// - y-offset-key (string, int): The key at which the `y-offset` coordinate is 
///   described in each `data` entry. If `none`, the `y-offset` is assumed to be `0` for
///   each entry. If `y-offset-key` is not contained within an entry despite being set,
///   the `y-offset` is assumed to be `0`.
/// - bar-width (float): The width of the bar along the `x` axis, in data-viewport space.
///   The bar is drawn centered about its `x` coordinate, therefore, the bar extends by
///   $#raw("bar-width")\/2$ either side.
/// - label (content): The label to be shown in the legend. If `none`, no entry is shown
///   in the legend.
/// - style (style): Style to use, can be used with a `palette` function
/// - axes (axes): Name of the axes to use for plotting. Reversing the axes
///   means rotating the plot by 90 degrees.
#let bar(
  data,
  x-key: 0,
  y-key: 1,
  y-offset-key: none,
  bar-width: 0.5,
  label: none,
  style: (:),
  axes: ("x", "y")
) = {
  let x-domain = (
    calc.min(..data.map(it => {it.at(x-key) - bar-width / 2})),
    calc.max(..data.map(it => {it.at(x-key) + bar-width / 2})),
  )

  let y-domain = if y-offset-key != none {
    (
      calc.min(
        ..data.map(it=>{it.at(y-key) + it.at(y-offset-key, default: 0)}),
        ..data.map(it=>{it.at(y-offset-key, default: 0)})
      ),
      calc.max(
        ..data.map(it=>{it.at(y-key) + it.at(y-offset-key, default: 0)}),
        ..data.map(it=>{it.at(y-offset-key, default: 0)})
      )
    )
  } else {
    (
      0,
      calc.max(..data.map(it=>{it.at(y-key)})),
    )
  }

  return ((
    type: "bar",
    label: label,
    axes: axes,

    bar-data: data,
    x-key: x-key,
    y-key: y-key,
    y-offset-key: y-offset-key,

    x-domain: x-domain,
    y-domain: y-domain,

    bar-width: bar-width,
    style: style,
    plot-prepare: _prepare,
    plot-stroke: _stroke,
    plot-fill: _fill,
    plot-legend-preview: _legend-preview
  ),)
}
