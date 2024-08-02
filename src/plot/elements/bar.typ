#import "/src/cetz.typ": draw

#let _prepare(self, ctx) = {

  self.stroke-paths = self.bar-data.map(d=>{

    let (x,y) = (d.at(self.x-key),d.at(self.y-key))
    let base = if self.y-base-key != none {
      d.at(self.y-base-key, default: 0)
    } else {
      0
    };

    (ctx.compute-stroke-paths)(
      (
        (x - self.bar-width/2, base),
        (x - self.bar-width/2, y+base),
        (x + self.bar-width/2, y+base),
        (x + self.bar-width/2, base),
      ), 
      ctx,
    )
  })

  self.fill-paths = self.bar-data.map(d=>{
    let (x,y) = (d.at(self.x-key),d.at(self.y-key))
    let base = if self.y-base-key != none {
      d.at(self.y-base-key, default: 0)
    } else {
      0
    };

    (ctx.compute-fill-paths)(
      (
        (x - self.bar-width/2, base),
        (x - self.bar-width/2, y+base),
        (x + self.bar-width/2, y+base),
        (x + self.bar-width/2, base),
      ), 
      ctx,
    )
  })

  return self
}

#let _stroke(self, ctx) = {
  for rects in self.stroke-paths {
    for p in rects {
      draw.line(..p, ..self.style, fill: none)
    }
  }
}

#let _fill(self, ctx) = {
  for d in self.fill-paths {
    for p in d {
      draw.line(..p, ..self.style, stroke: none)
    }
  }
}

#let _legend-preview(self) = {
  draw.rect((0,0), (1,0.5), ..self.style)
}

#let bar(
  data,
  x-key: 0,
  y-key: 1,
  y-base-key: none,
  bar-width: 0.5,
  label: none,
  style: (:),
  axes: ("x", "y")
) = {

  let x-domain = (
    calc.min(..data.map(it=>{it.at(x-key)-bar-width})),
    calc.max(..data.map(it=>{it.at(x-key)+bar-width})),
  )

  let y-domain = if y-base-key != none {
    (
      calc.min(
        ..data.map(it=>{it.at(y-key)+it.at(y-base-key, default: 0)}),
        ..data.map(it=>{it.at(y-base-key, default: 0)})
      ),
      calc.max(
        ..data.map(it=>{it.at(y-key)+it.at(y-base-key, default: 0)}),
        ..data.map(it=>{it.at(y-base-key, default: 0)})
      )
    )
  } else {
    (
      0,
      calc.max(..data.map(it=>{it.at(y-key)})),
    )
  }

  return ((
    type: "bar",
    label: label,
    axes: axes,

    bar-data: data,
    x-key: x-key,
    y-key: y-key,
    y-base-key: y-base-key,

    x-domain: x-domain,
    y-domain: y-domain,

    bar-width: bar-width,
    style: style,
    plot-prepare: _prepare,
    plot-stroke: _stroke,
    plot-fill: _fill,
    plot-legend-preview: _legend-preview
  ),)

  
}