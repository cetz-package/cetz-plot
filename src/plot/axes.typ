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
#let axis(
  min: -1, 
  max: 1, 
  label: none,
  ticks: (
    step: auto,
    minor-step: none,
    unit: none, 
    decimals: 2, 
    grid: false,
    format: "float"
  ),
  mode:
  auto, 
  base: auto
) = (
  min: min, 
  max: max, 
  ticks: ticks, 
  label: label, 
  inset: (0, 0), 
  show-break: false, 
  mode: mode, 
  base: base
)