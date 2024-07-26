#import "/src/cetz.typ": draw, process, util, matrix

#import "util.typ"
#import "sample.typ"

#let _prepare(self, ctx) = {
  let (x, y) = (ctx.x, ctx.y)

  // bin the data
  let (min, max) = (calc.min(..self.data),calc.max(..self.data))
  
  let binned = self.data.sorted().fold( (0,)*self.bins, (acc, it) => {
    let bin =  int(calc.rem(5 * (it - min) / (max - min), 5))
    acc.insert(bin, acc.at(bin) + 1)
    return acc
  })

  self.line-data = ()

  // Generate stroke paths
  // self.stroke-paths = util.compute-stroke-paths(self.line-data,
  //   (x.min, y.min), (x.max, y.max))

  // Compute fill paths if filling is requested
  self.fill = self.at("fill", default: false)
  if self.fill {
    self.fill-paths = util.compute-fill-paths(
      self.line-data,
      (x.min, y.min), 
      (x.max, y.max)
    )
  }

  return self
}

#let _stroke(self, ctx) = {
  let (x, y) = (ctx.x, ctx.y)

  // for p in self.stroke-paths {
  //   draw.line(..p, fill: none)
  // }
}

#let _fill(self, ctx) = {
  // fill-segments-to(self.fill-paths, y.min)
}

#let violin( 
  data,
  style: (:),
  axes: ("x", "y"),
  bins: 7,
) = {

  ((
    type: "violin",
    axes: axes,
    data: data,
    bins: bins,
    style: style,
    plot-prepare: _prepare,
    plot-stroke: _stroke,
    plot-fill: _fill,
    plot-legend-preview: self => {
      draw.rect((0,0), (1,1), ..self.style)
    }
  ),)


}