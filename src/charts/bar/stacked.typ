#import "/src/cetz.typ": canvas
#import "/src/plot.typ": plot
#import "/src/plot/add.typ" as add: series, bar

/// Render a stacked bar chart
///   ```example
///   cetz-plot.chart.bar.stacked(
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
/// - ..plot-args (variadic): Additional plotting parameters and axis options to be passed to @@plot
#let stacked(
  data,
  labels: (),
  label-key: 0,
  y-keys: (1,),
  y-error-keys: none,
  bar-width: 0.5,
  ..plot-args
) = {
  let series-count = y-keys.len()
  let cluster-width = series-count * bar-width
  let offsets = (0,)*series-count

  let series-data = ()

  for (series-index, y-key) in y-keys.enumerate() {

    series-data.push(
      (
        label: if label-key != none {labels.at(series-index)},
        data: for (observation-index, observation) in data.enumerate() { 
          let x = observation-index
          let y = observation.at(y-key, default: 0)
          let y-offset = offsets.at(observation-index)
          offsets.at(observation-index) += y
          ((
            x: x,
            y: y,
            y-offset: y-offset,
          ),)
        }
      )
    )
  }

  plot(
    x-tick-step: if label-key == none {1},
    x-ticks: if label-key != none {
      data.map((d)=>d.at(label-key, default: none)).enumerate()
    } else {()},
    ..plot-args,
    for (label, data) in series-data {
      add.series(
        label: label,
        {
          add.bar(
            data,
            x-key: "x", y-key: "y", y-offset-key: "y-offset",
            bar-width: bar-width,
          )

          if y-error-keys != none {
            add.errorbar(
              data,
              x-key: "x",y-key: "y", y-error-key: "y-err",
            )
          }
        }
      )
    }
  )
}