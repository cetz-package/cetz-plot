#import "/src/cetz.typ": canvas
#import "/src/plot.typ": plot
#import "/src/plot/add.typ" as add: series, bar

// TODO: There's some refactoring opportunities here but I don't want to put
// the cart before the horse

///
/// - ..plot-args (variadic): Additional plotting parameters and axis options to be passed to @@plot
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

///
/// - ..plot-args (variadic): Additional plotting parameters and axis options to be passed to @@plot
#let stacked(
  data,
  labels: (),
  label-key: 0,
  y-keys: (1,),
  y-error-keys: none, // TODO: Can stacked bars have error?
  bar-width: 0.5,
  x-spacing: 1, // TODO: Consider naming of this argument
  ..plot-args
) = canvas({
  let series-count = y-keys.len()
  let cluster-width = series-count * bar-width
  let offsets = (0,)*series-count

  let series-data = ()

  for (series-index, y-key) in y-keys.enumerate() {

    series-data.push(
      (
        label: if label-key != none {labels.at(series-index)},
        data: for (observation-index, observation) in data.enumerate() { 
          let x = observation-index * (x-spacing)
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
    x-tick-step: if label-key == none {x-spacing},
    x-ticks: if label-key != none {
      data.map(d=>d.at(label-key, default: none)).enumerate()
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
})