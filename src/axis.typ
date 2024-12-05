#import "/src/ticks.typ"
#import "/src/plot/util.typ"

// Grid modes
#let _get-grid-mode(mode) = {
  return if mode == true or mode == "major" {
    1
  } else if mode == "minor" {
    2
  } else if mode == "both" {
    3
  } else {
    0
  }
}

/// Transform linear axis value to linear space (low, high)
#let _transform-lin(ax, value, low, high) = {
  let range = high - low

  return low + (value - ax.min) * (range / (ax.max - ax.min))
}

/// Transform log axis value to linear space (low, high)
#let _transform-log(ax, value, low, high) = {
  let range = high - low

  let f(x) = {
    calc.log(calc.max(x, util.float-epsilon), base: ax.base)
  }

  return low + (f(value) - f(ax.min)) * (range / (f(ax.max) - f(ax.min)))
}

/// Linear Axis Constructor
#let linear(name, min, max, ..options) = (
  label: [#name],
  name: name, min: min, max: max, base: 10, transform: _transform-lin,
  auto-domain: (none, none),
  ticks: (step: auto, minor-step: none, format: auto, list: none),
  grid: 0,
  compute-ticks: ticks.compute-ticks.with("lin"),
) + options.named()

/// Log Axis Constructor
#let logarithmic(name, min, max, base, ..options) = (
  label: [#name],
  name: name, min: min, max: max, base: base, transform: _transform-log,
  auto-domain: (none, none),
  ticks: (step: auto, minor-step: none, format: auto, list: none),
  grid: 0,
  compute-ticks: ticks.compute-ticks.with("log"),
) + options.named()

// Prepare axis
#let prepare(ptx, ax) = {
  ax.grid = _get-grid-mode(ax.grid)
  if ax.min == none { ax.min = ax.auto-domain.at(0) }
  if ax.max == none { ax.max = ax.auto-domain.at(1) }
  if ax.min == none or ax.max == none { ax.min = -1e-6; ax.max = +1e-6 }
  if "compute-ticks" in ax {
    ax.computed-ticks = (ax.compute-ticks)(ax)
  }
  return ax
}

/// Transform an axis value to a linear value between low and high
/// - ax (axis): Axis
/// - value (number): Value to transform from axis space to linear space
/// - low (number): Linear minimum
/// - high (number): Linear maximum
#let transform(ax, value, low, high) = {
  return (ax.transform)(ax, value, low, high)
}
