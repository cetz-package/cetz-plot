#import "/src/cetz.typ": draw, styles, palette
#import "/src/plot.typ": plot
#import "/src/plot/add.typ" as add: series, bar, errorbar
#import "style.typ": barchart-default-style

#let plotter(
  data,
  series-data,
  x-key: "x", 
  y-key: "y",
  y-error-key: none,
  y-offset-key: none,
  label-key: none,
  bar-width: 0.7,
  bar-style: palette.red,
  axes: ("x", "y"),
  ..plot-args,
) = {
  draw.group(ctx => {
  /*
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
        data.map((d)=>d.at(label-key, default: none)).enumerate()
      } else {()},

      y-grid: true,

      plot-style: bar-style,
      ..plot-args,

      // Body argument: An array of series
      for (label, data) in series-data {
        add.series(
          label: label,
          {
            add.bar(
              data,
              x-key: x-key,
              y-key: y-key,
              y-offset-key: y-offset-key,
              bar-width: bar-width,
              axes: axes,
            )

            if y-error-key != none {
              add.errorbar(
                data,
                x-key: x-key,y-key: y-key, y-error-key: y-error-key,
                axes: axes,
              )
            }
          }
        )
      }
    )
  */
  })
}
