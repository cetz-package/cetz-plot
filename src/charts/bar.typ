#import "/src/cetz.typ": canvas
#import "/src/plot.typ": plot
#import "/src/plot/add.typ" as add: series, bar


#let bar(
  data,
  labels: (),
  label-key: none,
  y-keys: (1,),
  y-error-keys: none,
  // Handle inter-cluster spacing and intra-cluster
  mode: "cluster",
  ..plot-args
) = canvas({
  plot(
    ..plot-args,
    // TODO: Handle x-labels
    { 

      // TODO: Preprocess data into more convenient format
      let series = if mode == "cluster" {
        for (index, y-key) in y-keys.enumerate() {
          ((
            label: if label-key != none {labels.at(index)},
            data: data.enumerate().map(((k,v))=>{
              (
                x: k,
                y: v.at(y-key),
                y-err: if (y-error-keys != none) {
                  v.at(y-error-keys.at(index))
                }
              )
            })
          ),)
        }
      } else {()}

      // Render as series
      for (label, data) in series {
        add.series(
          label: label,
          {
            add.bar(
              data,
              x-key: "x",
              y-key: "y",
            )

            // if y-error-keys != none {
            //   add.errorbar(
            //     data,
            //     // TODO
            //   )
            // }
          }
        )
      }
    }
  )
})