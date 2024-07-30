#import "/src/cetz.typ": util, draw, vector, matrix, styles, process, drawable, path-util, process

// Construct Axis Object
//
// - min (number): Minimum value
// - max (number): Maximum value
// - ticks (dictionary): Tick settings:
//     - step (number): Major tic step
//     - minor-step (number): Minor tic step
//     - unit (content): Tick label suffix
//     - decimals (int): Tick float decimal length
// - label (content): Axis label
// - mode (string): Axis scaling function. Takes `lin` or `log`
// - base (number): Base for tick labels when logarithmically scaled.
#let axis(min: -1, max: 1, label: none,
          ticks: (step: auto, minor-step: none,
                  unit: none, decimals: 2, grid: false,
                  format: "float"
                  ),
          mode: auto, base: auto) = (
  min: min, max: max, ticks: ticks, label: label, inset: (0, 0), show-break: false, mode: mode, base: base
)

// Prepares the axis post creation. The given axis
// must be completely set-up, including its intervall.
// Returns the prepared axis
#let prepare-axis(ctx, axis, name) = {
  let style = styles.resolve(ctx.style, root: "axes",
                             base: preset.scientific.default-style-scientific)
  style = _prepare-style(ctx, style)
  style = _get-axis-style(ctx, style, name)

  if type(axis.inset) != array {
    axis.inset = (axis.inset, axis.inset)
  }

  axis.inset = axis.inset.map(v => util.resolve-number(ctx, v))

  if axis.show-break {
    if axis.min > 0 {
      axis.inset.at(0) += style.break-point.width
    } else if axis.max < 0 {
      axis.inset.at(1) += style.break-point.width
    }
  }

  return axis
}

#import "axes/viewport.typ": transform-vec, axis-viewport

#import "axes/grid.typ": draw-grid-lines
#import "axes/ticks.typ": place-ticks-on-line
#import "axes/preset.typ": scientific, scientific-polar, school-book