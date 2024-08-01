#import "/src/cetz.typ": draw
#import "/src/plot/mark.typ"

#let _prepare(self, ctx) = {
  for (key, value) in self.body.enumerate() {
    value.style = self.style
    self.body.at(key) = (value.plot-prepare)(value, ctx)
  }
  return self
}

#let _stroke(self, ctx) = {
  for (key, value) in self.body.enumerate() {
    if "plot-stroke" in value {
      (value.plot-stroke)(value, ctx)
    }
    
    if "mark" in value and value.mark != none {
      // draw.group({
        // draw.set-style(..value.style, ..value.mark-style)
        // mark.draw-mark(value.data, ctx, value.mark, value.mark-size, )
      // })
    }
  }
}

#let _fill(self, ctx) = {
  for (key, value) in self.body.enumerate() {
    if not "plot-fill" in value {continue}
    (value.plot-fill)(value, ctx)
  }
}

#let _legend-preview(self) = {
  for (key, value) in self.body.enumerate() {
    if not "plot-legend-preview" in value {continue}
    (value.plot-legend-preview)(value)
  }
}


#let series(
  body, 
  label: none,
  style: (:),
  axes: ("x", "y")
) = {

  let x-domain = (
    calc.min(
      ..body.map(it=>{
        if ("x-domain" in it) and (it.x-domain != none) {
          it.x-domain.at(0)
        } else {0}
      })
    ),
    calc.max(
      ..body.map(it=>{
        if ("x-domain" in it) and (it.x-domain != none) {
          it.x-domain.at(1)
        } else {0}
      })
    ),
  )

  let y-domain = (
    calc.min(
      ..body.map(it=>{
        if ("y-domain" in it) and (it.y-domain != none) {
          it.y-domain.at(0)
        } else {0}
      })
    ),
    calc.max(
      ..body.map(it=>{
        if ("y-domain" in it) and (it.y-domain != none) {
          it.y-domain.at(1)
        } else {0}
      })
    ),
  )

  ((
    type: "series",
    label: label,
    body: body,
    axes: axes,
    style: style,
    x-domain: x-domain,
    y-domain: y-domain,
    plot-prepare: _prepare,
    plot-stroke: _stroke,
    plot-fill: _fill,
    plot-legend-preview: _legend-preview,
  ),)
}