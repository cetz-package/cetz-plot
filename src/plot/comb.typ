#import "/src/cetz.typ": draw, vector
#import "util.typ"
#import "line.typ"
#import "annotation.typ"

#let _prepare(self, ctx) = {
  let (x-axis, y-axis) = (ctx.x, ctx.y)
  self.stroke-paths = self.line-data
    .map(((x, y, s, ..)) => {
        (
          lines: util.compute-stroke-paths(
            ((x, 0), (x,y)), 
            x-axis, 
            y-axis
          ),
          style: s,
        )
        
      })
  self
}

#let _fill(self, ctx) = {}

#let _stroke(self, ctx) = {
  for (lines, style) in self.stroke-paths {
    for p in lines {
      draw.line(..p, fill: none, ..self.style, ..style)
    }
  }
}

#let _legend-preview(self) = {
  draw.line((0,.5), (1,.5), ..self.style)
}

#let add-comb(
  domain: auto,
  mz-key: 0,
  intensity-key: 1,
  label-key: none,
  style-key: none,
  style: (:),
  mark: none,
  mark-size: 0.05,
  mark-style: (:),
  axes: ("x", "y"),
  label: none,
  label-padding: none,
  annotations: auto,
  data
) = {

  let line-data = data.map(d=>(
    d.at(mz-key), 
    d.at(intensity-key),
    if style-key != none {d.at(style-key, default: none)} else {style}
  ))

  let x-domain = (
    calc.min(..line-data.map(t => t.at(0))),
    calc.max(..line-data.map(t => t.at(0)))
  )

  let y-domain = if line-data != none {(
    calc.min(..line-data.map(t => t.at(1))),
    calc.max(..line-data.map(t => t.at(1)))
  )}

  let annotations = if annotations == auto {
    if (label-key == none) {
      ()
    } else {
      data.filter(it=>it.at(label-key, default: none) != none)
    }
  } else if annotations == none {
    ()
  } else {
    annotations
  }

  ((:
    type: "comb",
    label: label,
    data: data, /* Raw data */
    line-data: line-data, /* Transformed data */
    axes: axes,
    x-domain: x-domain,
    y-domain: y-domain,
    style: style,
    mark: mark,
    mark-size: mark-size,
    mark-style: mark-style,
    plot-prepare: _prepare,
    plot-fill: _fill,
    plot-stroke: _stroke,
    // plot-legend-preview: _legend-preview,
    mz-key: mz-key,
    intensity-key: intensity-key,
    label-key: label-key,
    width: 0.5,
  ),)

  for (x, y, a) in annotations {
    annotation.annotate(
      draw.content((x,y), [#a], anchor: "south"),
      axes: ("x", "y"), 
      resize: true, 
      padding: none, 
      background: false
    )
  }

}

