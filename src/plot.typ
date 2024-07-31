#import "plots/orthorect-2d.typ"
#import "plots/barycentric-2d.typ"

// TODO: Refactor this into a better way of providing palettes

#let default-colors = (blue, red, green, yellow, black)

#let default-plot-style(i) = {
  let color = default-colors.at(calc.rem(i, default-colors.len()))
  return (stroke: color,
          fill: color.lighten(75%))
}

#let default-mark-style(i) = {
  return default-plot-style(i)
}

// Consider splitting into sevaral files
#let _create-axis-dict()

#let plot(
  body,
  size: (1,1),
  axis-style: orthorect-2d,
  name: none,
  plot-style: default-plot-style,
  mark-style: default-mark-style,
  legend: auto,
  legend-anchor: auto,
  legend-style: (:),
  ..options
) = draw.group(name: name, ctx => {

  // TODO: Assert cetz min version here!

  let data = ()
  let anchors = ()
  let annotations = ()
  let body = if body != none { body } else { () }

  for cmd in body {
    assert(type(cmd) == dictionary and "type" in cmd,
           message: "Expected plot sub-command in plot body")

    if cmd.type == "anchor" {
      anchors.push(cmd)
    } else if cmd.type == "annotation" {
      annotations.push(cmd)
    } else { 
      data.push(cmd) 
    }
  }

})