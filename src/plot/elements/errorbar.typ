#import "/src/cetz.typ": draw, util, vector

#let _draw-whisker(pt, dir, ..style) = {
  let a = vector.add(pt, vector.scale(dir, -1))
  let b = vector.add(pt, vector.scale(dir, +1))

  draw.line(a, b, ..style)
}

#let draw-errorbar(pt, x, y, x-whisker-size, y-whisker-size, style) = {
  if type(x) != array { x = (-x, x) }
  if type(y) != array { y = (-y, y) }

  let (x-min, x-max) = x
  let x-min-pt = vector.add(pt, (x-min, 0))
  let x-max-pt = vector.add(pt, (x-max, 0))
  if x-min != 0 or x-max != 0 {
    draw.line(x-min-pt, x-max-pt, ..style)
    if x-whisker-size > 0 {
      if x-min != 0 {
        _draw-whisker(x-min-pt, (0, x-whisker-size), ..style)
      }
      if x-max != 0 {
        _draw-whisker(x-max-pt, (0, x-whisker-size), ..style)
      }
    }
  }

  let (y-min, y-max) = y
  let y-min-pt = vector.add(pt, (0, y-min))
  let y-max-pt = vector.add(pt, (0, y-max))
  if y-min != 0 or y-max != 0 {
    draw.line(y-min-pt, y-max-pt, ..style)
    if y-whisker-size > 0 {
      if y-min != 0 {
        _draw-whisker(y-min-pt, (y-whisker-size, 0), ..style)
      }
      if y-max != 0 {
        _draw-whisker(y-max-pt, (y-whisker-size, 0), ..style)
      }
    }
  }
}

#let _prepare(self, ctx) = {
  return self
}

#let _stroke(self, ctx) = {
  let x-whisker-size = self.whisker-size * ctx.y-scale
  let y-whisker-size = self.whisker-size * ctx.x-scale

  for d in self.data {
    draw-errorbar(
      (d.at(self.x-key),d.at(self.y-key)),
      if self.x-error-key != none {d.at(self.x-error-key, default: 0)} else {0},
      if self.y-error-key != none {d.at(self.y-error-key, default: 0)} else {0},
      x-whisker-size,
      y-whisker-size,
      self.style
    )
  }

}

/// Add x- and/or y-error bars
///
/// - pt (tuple): Error-bar center coordinate tuple: `(x, y)`
/// - x-error: (float,tuple): Single error or tuple of errors along the x-axis
/// - y-error: (float,tuple): Single error or tuple of errors along the y-axis
/// - mark: (none,string): Mark symbol to show at the error position (`pt`).
/// - mark-size: (number): Size of the mark symbol.
/// - mark-style: (style): Extra style to apply to the mark symbol.
/// - whisker-size (float): Width of the error bar whiskers in canvas units.
/// - style (dictionary): Style for the error bars
/// - label: (none,content): Label to tsh
/// - axes (axes): Plot axes. To draw a horizontal growing bar chart, you can swap the x and y axes.
#let errorbar(data,
              x-key: 0,
              y-key: 1,
              x-error-key: none,
              y-error-key: none,
              x-error: 0,
              y-error: 0,
              label: none,
              whisker-size: .2,
              style: (:),
              axes: ("x", "y")) = {
  assert(x-error-key != none or y-error-key != none,
    message: "Either x-error-key or y-error-key must be set.")

  // x-error.at(0) = calc.abs(x-error.at(0)) * -1
  // y-error.at(0) = calc.abs(y-error.at(0)) * -1

  let x-domain = if x-error-key != none {
    (
      calc.min(..data.map(it=>(it.at(x-key)-it.at(x-error-key)))),
      calc.max(..data.map(it=>(it.at(x-key)+it.at(x-error-key))))
    )
  }

  let y-domain = if y-error-key != none {
    (
      calc.min(..data.map(it=>(it.at(y-key)-it.at(y-error-key)))),
      calc.max(..data.map(it=>(it.at(y-key)+it.at(y-error-key))))
    )
  }

  return ((
    type: "errorbar",
    label: label,
    axes: axes,

    data: data,
    x-key: x-key,
    y-key: y-key,
    x-error-key: x-error-key,
    y-error-key: y-error-key,

    x-domain: x-domain,
    y-domain: y-domain,

    whisker-size: whisker-size,
    style: style,
    plot-prepare: _prepare,
    plot-stroke: _stroke,
    plot-legend-preview: (self) => {
      draw-errorbar(
        (0.5, 0.5),
        0, 0.4,
        0.01, 0.1,
        self.style
      )
    }
  ),)
}