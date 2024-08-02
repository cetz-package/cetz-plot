#import "/src/cetz.typ": canvas
#import "plotter.typ": plotter

/// Render a clustered bar chart
///   ```example-nocanvas
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
#let clustered(
  data,
  labels: (),
  label-key: 0,
  y-keys: (1,),
  y-error-keys: none,
  bar-width: 0.7,
  bar-spacing: 0,
  ..plot-args
) = canvas({
  let series-count = y-keys.len()
  bar-width /= series-count
  let cluster-width = series-count * bar-width + (series-count - 1) * bar-spacing
  let offsets = (0,)*series-count

  let series-data = ()

  for (series-index, y-key) in y-keys.enumerate() {

    series-data.push(
      (
        label: if label-key != none {labels.at(series-index)},
        data: for (observation-index, observation) in data.enumerate() { 
          let x = observation-index - cluster-width/2 + series-index * (bar-width + bar-spacing) + bar-width/2
          let y = observation.at(y-key, default: 0)
          offsets.at(observation-index) += y
          ((
            x: x,
            y: y,
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
    y-error-key: none,
    label-key: none,
    bar-width: bar-width,
    ..plot-args,
  )
})