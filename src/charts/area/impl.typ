#import "/src/cetz.typ": canvas, draw, styles, palette
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


#let stacked(
  data,
  label-key: none,
  x-key: 0,
  y-keys: (1,),
  area-style: palette.red,
  axes: ("x", "y"),
  ..plot-args
) = {

  let series-data = ()
  for (series-index, data) in data.enumerate(){
    series-data.push(
      (
        label: if label-key != none {data.at(label-key)},
        data: y-keys.map(k=>data.at(k, default: 0))
      )
    )
  }
  
  plotter(
    series-data, 
    number-points: y-keys.len(),
    x-key: x-key,
    area-style: area-style,
    axes: axes,
    stack: true,
    ..plot-args
  )
}

#let stacked100(
  data,
  label-key: none,
  x-key: 0,
  y-keys: (1,),
  area-style: palette.red,
  axes: ("x", "y"),
  ..plot-args
) = stacked(
  data.map(d=>{
    let sum = y-keys.map(k=>data.map(d=>d.at(k, default: 0)).sum())
    for (index, key) in y-keys.enumerate() {
      d.at(key) /= sum.at(index)
    }
    d
  }),
  label-key: label-key,
  x-key: x-key,
  y-keys: y-keys,
  area-style: area-style,
  axes: axes,
  y-tick-step: 0.2,
  y-format: (it)=>{$#{it*100}%$},
  ..plot-args
)