#import "/src/cetz.typ": draw

#import "util.typ"
#import "sample.typ"


#let kernal-normal(x, stdev: 1.5) = {
  (1/calc.sqrt(2*calc.pi*calc.pow(stdev,2))) * calc.exp( - (x*x)/(2*calc.pow(stdev,2)))
}


#let _violin-render(self, ctx, violin, filling: true) = {
  let path = range(self.samples)
              .map((t)=>violin.min + (violin.max - violin.min) * (t /self.samples ))
              .map((u)=>(u, (violin.convolve)(u)))
              .map(((u,v)) => {
                (violin.x-position + v, u)
              })

  if self.side == "both"{ 
    path += path.rev().map(((x,y))=> {(2 * violin.x-position - x,y)})
  } else if self.side == "left"{
    path = path.map( ((x,y))=>{(2 * violin.x-position - x,y)})
  }

  let (x, y) = (ctx.x, ctx.y)
  let stroke-paths = util.compute-stroke-paths(path, (x.min, y.min), (x.max, y.max))

  for p in stroke-paths{
    let args = arguments(..p, closed: self.side == "both")
    if filling {
      args = arguments(..args, stroke: none)
    } else {
      args = arguments(..args, fill: none)
    }
    draw.line(..args)
  }
}

#let _plot-prepare(self, ctx) = {
  self.violins = self.data.map(entry=> {
    let points = entry.at(self.y-key)
    let (min, max) = (calc.min(..points), calc.max(..points))
    let range = calc.abs(max - min)
    (
      x-position: entry.at(self.x-key),
      points: points,
      length: points.len(),
      min: min - (self.extents * range),
      max: max + (self.extents * range),
      convolve: (t) => {
        points.map((y)=>(self.kernel)((y - t)/self.bandwidth)).sum() / (points.len() * self.bandwidth)
      }
    )
  })
  return self
}

#let _plot-stroke(self, ctx) = { 
  for violin in self.violins {
    _violin-render(self, ctx, violin, filling: false)
  }
}

#let _plot-fill(self, ctx) = { 
  for violin in self.violins {
    _violin-render(self, ctx, violin, filling: true)
  }
}

#let _plot-legend-preview(self) = {
  draw.rect((0,0), (1,1), ..self.style)
}

#let violin( 
  data,
  x-key: 0,
  y-key: 1,
  side: "right", // "left", "right", "both"
  kernel: kernal-normal.with(stdev: 1.5),
  bandwidth: 1,
  extents: 0.25,

  samples: 50,
  style: (:),
  mark-style: (:),
  axes: ("x", "y"),
  label: none,
) = {

  ((
    type: "violins",

    data: data,
    x-key: x-key,
    y-key: y-key,
    side: side,
    kernel: kernel,
    bandwidth: bandwidth,
    extents: extents,

    samples: samples,
    style: style,
    mark-style: mark-style,
    axes: axes,
    label: label,

    plot-prepare: _plot-prepare,
    plot-stroke: _plot-stroke,
    plot-fill: _plot-fill,
    plot-legend-preview: _plot-legend-preview,
  ),)

  // for category in data {
  //   let (x, ys) = (category.at(x-key), category.at(y-key))
  //   let n = ys.len()
  //   let (min, max) = (calc.min(..ys), calc.max(..ys))
  //   let domain = (min - (max - min)*extend, max + (max - min)*extend)

  //   let convolve = (t, side: side)=>{
  //     let val = ys.map((y)=>kernel((y - t)/bandwidth)).sum()
  //     (x + (1/(n*bandwidth) * val) * if side == "left" {-1} else {1}, t)
  //   }

  //   if (side in ("left", "both")) {
  //     line.add(
  //       convolve.with(side: "left"),
  //       domain: domain,
  //       line: "raw",
  //       fill-type: "shape",
  //       fill: true,
  //       style: style
  //     )
  //   }

  //   if (side in ("right", "both")){
  //     line.add(
  //       convolve.with(side: "right"),
  //       domain: domain,
  //       line: "raw",
  //       fill-type: "shape",
  //       fill: true,
  //       style: style
  //     )
  //   }


  // }

}