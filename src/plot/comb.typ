#import "/src/cetz.typ": draw, vector
#import "util.typ"
#import "line.typ"
#import "annotation.typ"

// Internal: This function takes the line-data (a sanitized input) and calculates
//  which points should be visible, and if they are partially clipped, recalcuates
//  positions
#let _prepare(self, ctx) = {
  self.stroke-paths = self.line-data
    .map(
      ((x, y, style, ..)) => {(
        lines: util.compute-stroke-paths( ((x, 0), (x,y)), ctx.axes),
        style: style,
      )})
  self
}

// Visible: Draw the lines using the pre-calculated stroke paths from earlier.
//  The overall style is first applied, and then overriden
#let _stroke(self, ctx) = {
  for (lines, style) in self.stroke-paths {
    for p in lines {
      draw.line(..p, fill: none, ..self.style, ..style)
    }
  }
}

/// Add a comb plot to a plot environment.
///
/// Must be called from the body of a `plot(..)` command.
/// 
/// #example(```
///   let points = (
///     (0,4), 
///     (1,2), 
///     (2,5, (stroke: red)), 
///     (3,1), 
///     (4,3)
///   )
///   plot.plot(size: (12, 3), y-min: 0, x-inset: 0.5, y-inset: (0,0.5), {
///     plot.add-comb(
///       points, 
///       style-key: 2 // Indicate which key sfor tyle overrides (optional)
///     )
///   })
///   ```, vertical: true)
///
/// - data (array,dictionary): Array of 2D data points (and optionally a style
///   override)
/// - x-key (int,string): Key to use for retrieving an x-value from 
///   a single data entry. This value gets passed to the `.at(...)` 
///   function of a data item. Resulting value must be a number.
/// - y-key (int,string): Key to use for retrieving a 
///   y-value. Resulting value must be a number.
/// - style (style): Style to use, can be used with a `palette` function
/// - style-key (int,string,none): Key to use for retrieving a `style` 
///   with which to override the current style. Resulting value must 
///   be either a `style` or `none`
/// - mark (string): Mark symbol to place at each distinct value of the
///   graph. Uses the `mark` style key of `style` for drawing.
/// - mark-size (float): Mark size in cavas units
/// - mark-style (style): Style override for marks.
/// - axes (axes): Name of the axes to use for plotting. Reversing the axes
///   means rotating the plot by 90 degrees
/// - label (none, content): The name of the category to be shown in the legend.
#let add-comb(
  x-key: 0,
  y-key: 1,
  style-key: none,
  style: (:),
  mark: none,
  mark-size: 0.05,
  mark-style: (:),
  axes: ("x", "y"),
  label: none,
  data
) = {

  // Convert the input data into a sanitized format so that it isn't needed
  // to store those keys in the element dictionary
  let line-data = data.map(d=>(
    x: d.at(x-key), 
    y: d.at(y-key),
    style: if style-key != none {d.at(style-key, default: none)} else {style},
  ))

  // Calculate the domains along both axes
  let x-domain = (
    calc.min(..line-data.map(t => t.x)),
    calc.max(..line-data.map(t => t.x))
  )

  let y-domain = if line-data != none {(
    calc.min(..line-data.map(t => t.y)),
    calc.max(..line-data.map(t => t.y))
  )}

  ((:
    type: "comb", // internal type indentifier
    label: label,
    data: line-data.map(((x, y,..))=>(x,y)), /* X-Y data */
    line-data: line-data, /* formatted data */
    axes: axes,
    x-domain: x-domain,
    y-domain: y-domain,
    style: style,
    mark: mark,
    mark-size: mark-size,
    mark-style: mark-style,
    plot-prepare: _prepare,
    plot-stroke: _stroke,
  ),)

}
