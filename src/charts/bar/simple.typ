#import "/src/cetz.typ": canvas, palette, draw, styles
#import "/src/plot.typ": plot
#import "/src/plot/add.typ" as add: series, bar, errorbar
#import "/src/plot/axis-style.typ"
#import "style.typ": barchart-default-style

/// Render a single series as a barchart
///
///  ```example
///   cetz-plot.chart.bar.simple(
///     size: (4,4),
///     label-key: 0,
///     y-key: 1,
///     y-error-key: 2,
///     label: [label],
///     (
///       ([One], 1, 0.5),
///       ([Two], 3, 0.75),
///       ([Three], 2, 1),
///     ),
///   )
///   ```
/// - data (array): An array of bars to plot. Each entry can include a label
///   for the bar, shown on the `x` axis, a `y` coordinates that
///   represents the magnitude of a bar that starts at 0, and optionally a
///   `y-error` magnitude.
/// - label (content, none): Optional label to be shown in legend
/// - label-key (string, int): The key at which the x-axis label is described in
///   each data entry.
/// - y-key (string, int): The key at which the `y` coordinate is described in each
///   data entry.
/// - y-error-key (string, int, none): Optionally where `y-error` coordinate is 
///   described in each data entry. 
/// - bar-width (float): The width of the bar along the `x` axis, in data-viewport
///   space. The bar is drawn centered about its `x` coordinate, therefore, the bar 
///   extends by $#raw("bar-width")\/2$ either side.
/// - bar-style (style): Style to use, can be used with a `palette` function
/// - axes (axes): Name of the axes to use for plotting. Reversing the axes
///   means rotating the plot by 90 degrees. 
/// - ..plot-args (variadic): Additional plotting parameters and axis options to be 
///   passed to @@plot
#let simple(
  data,
  label: none,
  label-key: 0,
  y-key: 1,
  y-error-key: none,
  bar-width: 0.7,
  bar-style: palette.red,
  axes: ("x", "y"),
  ..plot-args
) = {

  let data = data.enumerate().map(((index, entry))=> (
    index,
    entry.at(y-key, default: 0),
    if y-error-key != none {entry.at(y-error-key, default: none)},
    entry.at(label-key, default: none)
  ))

  draw.group(ctx => {

    // Setup styles
    let style = styles.resolve(
      ctx.style, 
      merge: (:),
      root: "barchart", 
      base: barchart-default-style
    )
    draw.set-style(..style)

    plot(
      // To do: Is there a better way to setup the x-axis using custom axis-style
      x-min: -0.75, x-max: data.len() - 0.25,
      x-tick-step: if label-key == none {1},
      x-ticks: if label-key != none {
        data.map((d)=>d.at(3, default: none)).enumerate()
      } else {()},

      y-grid: true,

      plot-style: bar-style,
      ..plot-args,
      {
        add.series(
          label: label,
          {
            add.bar(
              data,
              x-key: 0,
              y-key: 1,
              bar-width: bar-width,
              axes: axes,
            )

            if y-error-key != none {
              add.errorbar(
                data,
                x-key: 0,
                y-key: 1, 
                y-error-key: 2,
                axes: axes,
              )
            }
          }
        )
      }
    )
  })
}
