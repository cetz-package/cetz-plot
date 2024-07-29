#import "/src/cetz.typ": util, draw, vector, matrix, styles, process, drawable, path-util, process
#import "axes/style.typ":  _prepare-style, _get-axis-style
#import "axes/preset.typ"
#import "axes/formats.typ"

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

// Get the default axis orientation
// depending on the axis name
#let get-default-axis-horizontal(name) = {
  return lower(name).starts-with("x")
}

// Setup axes dictionary
//
// - axis-dict (dictionary): Existing axis dictionary
// - options (dictionary): Named arguments
// - plot-size (tuple): Plot width, height tuple
#let setup-axes(ctx, axis-dict, options, plot-size) = {
  import "/src/axes.typ"

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
    axis-dict.at(name) = prepare-axis(ctx, axis, name)
  }

  return axis-dict
}




#import "axes/viewport.typ": transform-vec, axis-viewport

#import "axes/grid.typ": draw-grid-lines
#import "axes/ticks.typ": place-ticks-on-line
#import "axes/presets/scientific.typ": scientific
#import "axes/presets/school-book.typ": school-book