#import "/src/cetz.typ": draw, styles, palette
#import "/src/plot.typ": plot
#import "/src/plot/add.typ" as add: series, xy, fill-between
#import "style.typ": areachart-default-style

#let plotter(
  series-data,
  x-list: (),
  area-style: palette.red,
  axes: ("x", "y"),
  stack: false,
  ..plot-args,
) = draw.group(ctx => {

  // Setup styles
  let style = styles.resolve(
    ctx.style, 
    merge: (:),
    root: "areachart", 
    base: areachart-default-style
  )
  draw.set-style(..style)

  plot(
    y-grid: true,

    plot-style: area-style,
    ..plot-args,

    {
      let y-offsets = (0,) * x-list.len()
      for (label, data) in series-data {
        add.series(
          label: label,
          {
            add.fill-between(
              data.enumerate().map(((k,v))=>(x-list.at(k), v + y-offsets.at(k))), 
              data.enumerate().map(((k,v))=>(x-list.at(k), y-offsets.at(k))),
              style: (stroke: none),
            )

            add.xy(
              data.enumerate().map(((k,v))=>(x-list.at(k), v + y-offsets.at(k))),
            )

            if stack == true {
              for (key, value) in data.enumerate() {
                y-offsets.at(key) += value
              }
            }

          }
        )
      }
    }
  )

})
