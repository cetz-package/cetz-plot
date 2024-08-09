#import "/src/cetz.typ": canvas, palette
#import "plotter.typ": plotter

#let stacked(
  data,
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
        // label: if label-key != none {data.at(label-key)},
        label: none,
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
  label-key: 0,
  x-key: 1,
  y-keys: (2,),
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