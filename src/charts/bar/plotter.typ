#import "/src/plot.typ": plot
#import "/src/plot/add.typ" as add: series, bar, errorbar

#let plotter(
  data,
  series-data,
  x-key: "x", 
  y-key: "y",
  y-error-keys: none,
  label-key: none,
  bar-width: 0.7,
  ..plot-args,
) = plot(
  x-min: -0.75, x-max: data.len() - 0.25,
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
          x-key: x-key,
          y-key: y-key,
          bar-width: bar-width,
        )

        if y-error-keys != none {
          add.errorbar(
            data,
            x-key: x-key,y-key: y-key, y-error-key: y-error-key,
          )
        }
      }
    )
  }
)