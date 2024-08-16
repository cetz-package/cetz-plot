#import "/src/cetz.typ" as cetz: canvas, palette
#import "/src/plot.typ"
#import "/src/charts/environment.typ": chart

//#import "plotter.typ": plotter

/// Render a stacked bar chart
///   ```example
///   cetz-plot.chart.bar.stacked(
///     size: (4, 4),
///     (([One],   1, 1, 2, 3),
///      ([Two],   3, 1, 1 ,1),
///      ([Three], 3, 2, 1, 3)),
///     label-key: 0,
///     y-keys: (1, 2, 3, 4),
///     labels: (
///       $0 -> 24$, 
///       $25 -> 49$,
///       $50 -> 74$, 
///       $75 -> 100$),
///   )
///   ```
/// - data (array): An array of clusers to plot. Each entry can include a label
///   for the cluster, shown on the `x` axis, a number of `y` coordinates that
///   represent the magnitude of a bar that starts at 0, and optionally a
///   corresponding number of `y-error` magnitudes for each bar.
/// - labels (array): An array of either content or none, to be shown in the legend
///   for its corresponding series. The n'th y-keys series is labelled by the
///   n'th label (or none).
/// - label-key (string, int): The key at which the x-axis label is described in
///   each data entry.
/// - y-keys (array): The n'th entry in `y-keys` corresponds to the key at which 
///   the `y` coordinate can be found in each data entry, for the n'th series.
/// - y-error-keys (any): The n'th entry in `y-error-keys` corresponds to the key at 
///   which the `y-error` magnitude (as a float or as a tuple) can be found in
///   each data entry, for the n'th series.
/// - bar-width (float): The width of the bar along the `x` axis, in data-viewport
///   space. The bar is drawn centered about its `x` coordinate, therefore, the bar 
///   extends by $#raw("bar-width")\/2$ either side.
/// - bar-style (style): Style to use, can be used with a `palette` function
/// - axes (axes): Name of the axes to use for plotting. Reversing the axes
///   means rotating the plot by 90 degrees. 
/// - ..plot-args (variadic): Additional plotting parameters and axis options to be 
///   passed to @@plot
#let stacked(
  data,
  labels: (),
  label-key: 0,
  y-keys: (1,),
  y-error-keys: none,
  bar-width: 0.5,
  bar-style: palette.red,
  axes: ("x", "y"),
  ..plot-args
) = {
  let num-cols = data.len()
  let plot-args = plot-args.named()

  if "ticks" not in plot-args {
    plot-args.x-ticks = data.enumerate().map(((x, col)) => {
      (x, [#x])
    })
  }

  chart(x-tick-step: none, ..plot-args, style => {
    import "/src/plot/add.typ"

    let y-offset = (0,) * num-cols
    for (y, y-key) in y-keys.enumerate() {
      let row-data = data.enumerate().map(((x, col)) => {
        (x, col.at(y-key, default: 0), y-offset.at(x, default: 0))
      })

      y-offset = y-offset.enumerate().map(((x, offset)) => {
        offset + row-data.at(x).at(1)
      })

      add.bar(row-data,
        x-key: 0,
        y-key: 1,
        y-offset-key: 2,
        axes: axes,
        style: bar-style)
    }
  })
}

/// Render a stacked bar chart
///   ```example
///   cetz-plot.chart.bar.stacked100(
///     size: (4, 4),
///     (([One],   1, 1, 2, 3),
///      ([Two],   3, 1, 1 ,1),
///      ([Three], 3, 2, 1, 3)),
///     label-key: 0,
///     y-keys: (1, 2, 3, 4),
///     labels: (
///       $0 -> 24$, 
///       $25 -> 49$,
///       $50 -> 74$, 
///       $75 -> 100$),
///   )
///   ```
/// - data (array): An array of clusers to plot. Each entry can include a label
///   for the cluster, shown on the `x` axis, a number of `y` coordinates that
///   represent the magnitude of a bar that starts at 0, and optionally a
///   corresponding number of `y-error` magnitudes for each bar.
/// - labels (array): An array of either content or none, to be shown in the legend
///   for its corresponding series. The n'th y-keys series is labelled by the
///   n'th label (or none).
/// - label-key (string, int): The key at which the x-axis label is described in
///   each data entry.
/// - y-keys (array): The n'th entry in `y-keys` corresponds to the key at which 
///   the `y` coordinate can be found in each data entry, for the n'th series.
/// - y-error-keys (any): The n'th entry in `y-error-keys` corresponds to the key at 
///   which the `y-error` magnitude (as a float or as a tuple) can be found in
///   each data entry, for the n'th series.
/// - bar-width (float): The width of the bar along the `x` axis, in data-viewport
///   space. The bar is drawn centered about its `x` coordinate, therefore, the bar 
///   extends by $#raw("bar-width")\/2$ either side.
/// - bar-style (style): Style to use, can be used with a `palette` function
/// - axes (axes): Name of the axes to use for plotting. Reversing the axes
///   means rotating the plot by 90 degrees. 
/// - ..plot-args (variadic): Additional plotting parameters and axis options to be 
///   passed to @@plot
#let stacked100(
  data,
  labels: (),
  label-key: 0,
  y-keys: (1,),
  y-error-keys: none,
  bar-width: 0.5,
  bar-style: palette.red,
  axes: ("x", "y"),
  ..plot-args
) = stacked(
  data.map(d=>{
    let sum = y-keys.map(d.at.with(default: 0)).sum()
    assert(sum != 0,
      message: "Y value sum must be != 0!")
    for key in y-keys {
      d.at(key) /= sum
    }
    return d
  }), 
  labels: labels,
  label-key: label-key,
  y-keys: y-keys, 
  y-error-keys: y-error-keys,
  bar-width: bar-width,
  bar-style: bar-style,
  axes: axes,
  y-tick-step: 0.2,
  y-format: (it) => { $#{it * 100}%$ },
  ..plot-args
)
