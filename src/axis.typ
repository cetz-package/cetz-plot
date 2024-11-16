
/// Transform linear axis value to linear space (low, high)
#let _transform-lin(ax, value, low, high) = {
  let range = high - low

  return (value - ax.low) * (range / (ax.high - ax.low))
}

/// Transform log axis value to linear space (low, high)
#let _transform-log(ax, value, low, high) = {
  let range = high - low

  let f(x) = {
    calc.log(calc.max(x, util.float-epsilon), base: ax.base)
  }

  return (value - f(ax.low)) * (range / (f(ax.high) - f(ax.low)))
}

#let linear(low, high) = (
  low: low, high: high, transform: _transform-lin,
)

#let logarithmic(low, high, base) = (
  low: low, high: high, base: base, transform: _transform-log,
)

/// Transform an axis value to a linear value between low and high
/// - ax (axis): Axis
/// - value (number): Value to transform from axis space to linear space
/// - low (number): Linear minimum
/// - high (number): Linear maximum
#let transform(ax, value, low, high) = {
  return (ax.transform)(ax, value, low, high)
}
