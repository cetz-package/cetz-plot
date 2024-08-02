#import "/src/cetz.typ": canvas
#import "/src/plot.typ": plot
#import "/src/plot/add.typ" as add: series, bar

#let clustered(
  data,
  labels: (),
  label-key: 0,
  y-keys: (1,),
  y-error-keys: none,
  bar-width: 0.3,
  bar-gap: 0,
  cluster-gap: 1,
  ..plot-args
) = canvas({
  let series-count = y-keys.len()
  let cluster-width = series-count * bar-width
  let series-data = y-keys.enumerate().map( ((index, y-key)) => {
    (
      label: if label-key != none {labels.at(index)},
      data: data.enumerate().map(((k,v))=>{
        let cluster-position = k * (cluster-gap + cluster-width)
        let series-offset = (index) * bar-width
        (
          x: cluster-position + series-offset,
          y: v.at(y-key, default: 0),
          y-err: if (y-error-keys != none) {
            v.at(y-error-keys.at(index, default: 0))
          }
        )
      })
    )
  })

  plot(
    ..plot-args,
    for (label, data) in series-data {
      add.series(
        label: label,
        {
          add.bar(
            data,
            x-key: "x", y-key: "y",
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
})
