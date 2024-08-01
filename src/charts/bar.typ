#import "/src/cetz.typ": canvas

#let bar(
  size: (5, 5*0.75),
  data,
  labels: (),
  label-key: none,
  y-keys: (1,),
  y-error-keys: none,
  mode: "clustered",
  ..plot-args
) = canvas({
  cetz-plot.plot(
    size: size,
    ..plot-args,
    // TODO: Handle x-labels
    { 

      // TODO: Preprocess data into more convenient format

      // Render as series
      for (label, bar-data, error-data) in data {
        cetz-plot.add.series(
          label: label,
          {
            cetz-plot.add.bar(
              bar-data,
              // TODO
            )

            if y-error-keys != none {
              cetz-plot.add.errorbar(
                bar-data,
                // TODO
              )
            }
          }
        )
      }
    }
  )
})