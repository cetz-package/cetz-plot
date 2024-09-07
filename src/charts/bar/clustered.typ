#import "/src/cetz.typ": canvas, palette
#import "plotter.typ": plotter

/// Render a clustered bar chart
///
///  ```example
///   cetz-plot.chart.bar.clustered(
///     size: (4,4),
///     (
///       ([One],   1, 1, 2, 3),
///       ([Two],   3, 1, 1 ,1),
///       ([Three], 3, 2, 1, 3),
///     ),
///     label-key: 0,
///     y-keys: (1,2,3,4),
///     labels: (
///       $0 -> 24$, 
///       $25 -> 49$,
///       $50 -> 74$, 
///       $75 -> 100$
///     ),
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
/// - bar-spacing (float): The spacing between bars within a cluster, in data-viewprot 
///   space.
/// - bar-style (style): Style to use, can be used with a `palette` function
/// - axes (axes): Name of the axes to use for plotting. Reversing the axes
///   means rotating the plot by 90 degrees. 
/// - ..plot-args (variadic): Additional plotting parameters and axis options to be 
///   passed to @@plot
#let clustered(
  data,
  labels: (),
  label-key: 0,
  y-keys: (1,),
  y-error-keys: none,
  bar-width: 0.7,
  bar-spacing: 0,
  bar-style: palette.red,
  axes: ("x", "y"),
  ..plot-args
) = {
  let series-count = y-keys.len()
  bar-width /= series-count
  let cluster-width = series-count * bar-width + (series-count - 1) * bar-spacing

  let series-data = ()

  for (series-index, y-key) in y-keys.enumerate() {

    series-data.push(
      (
        label: if label-key != none {labels.at(series-index)},
        data: for (observation-index, observation) in data.enumerate() {
          let x = observation-index - cluster-width/2 + series-index * (bar-width + bar-spacing) + bar-width/2
          let y = observation.at(y-key, default: 0)

          ((
            x: x,
            y: y,
            y-error: if y-error-keys != none {
              let err-key = y-error-keys.at(series-index, default: none)
              if err-key != none {observation.at(err-key, default: 0)}
            }
          ),)
        }
      )
    )
  }

  plotter(
    data,
    series-data,
    x-key: "x", 
    y-key: "y",
    y-error-key: if y-error-keys != none {"y-error"},
    label-key: label-key,
    bar-width: bar-width,
    bar-style: bar-style,
    axes: axes,
    ..plot-args,
  )
}
