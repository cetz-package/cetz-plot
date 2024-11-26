#import "/src/plot/util.typ"
#import "/src/cetz.typ"
#import cetz: draw

#let make-cptx(ptx, old) = {
  let axes = old.axes.map(name => ptx.axes.at(name))
  return (
    axes: axes,
  )
}

#let draw-old(ptx, transform, body) = {
  if body != none {
    (ctx => {
      ctx.transform = ((1, 0, 0, 0),
                       (0,-1, 0, 0),
                       (0, 0, 1, 0),
                       (0, 0, 0, 1))
      let (ctx: _, drawables, bounds) = cetz.process.many(ctx, body)
      drawables = cetz.drawable.apply-transform(v => {
        let (x, y) = transform(v.slice(0, 2)).first()
        return (x, y, 0)
      }, drawables)

      return (
        ctx: ctx,
        drawables: drawables,
      )
    },)
  }
}

#let wrap(old) = {
  return (
    priority: 0,
    fn: ptx => {
      let old = old
      if "plot-prepare" in old {
        old = (old.plot-prepare)(old, make-cptx(ptx, old))
      }
      if "x-domain" in old {
        ptx = util.set-auto-domain(ptx, (old.axes.at(0),), (old.x-domain,))
      }
      if "y-domain" in old {
        ptx = util.set-auto-domain(ptx, (old.axes.at(1),), (old.y-domain,))
      }

      let data = (
        axes: old.axes,
        label: old.at("label", default: none),
        style: old.at("style", default: none),
        stroke: (ptx, transform) => {
          if "plot-stroke" in old {
            draw-old(ptx, transform, (old.plot-stroke)(old, make-cptx(ptx, old)))
          }
        },
        fill: (ptx, transform) => {
          if "plot-fill" in old {
            draw-old(ptx, transform, (old.plot-fill)(old, make-cptx(ptx, old)))
          }
        },
      )
      ptx.data.push(data)
      return ptx
    }
  )
}
