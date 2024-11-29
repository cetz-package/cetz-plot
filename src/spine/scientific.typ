#import "/src/cetz.typ"
#import "/src/axis.typ"
#import "/src/ticks.typ"
#import "/src/style.typ": prepare-style, get-axis-style, default-style
#import "/src/spine/util.typ": cartesian-axis-projection

#import cetz: vector, draw

///
#let cartesian-scientific(projections: none, name: none, style: (:)) = {
  return (
    name: name,
    draw: (ptx) => {
      let xy-proj = projections.at(0)
      let uv-proj = projections.at(1, default: xy-proj)
      let has-uv = projections.len() > 1
      let (x, y) = xy-proj.axes
      let (u, v) = uv-proj.axes

      let style = prepare-style(ptx, cetz.styles.resolve(ptx.cetz-ctx.style,
        root: "axes", merge: style, base: default-style))
      let x-style = get-axis-style(ptx, style, x.name)
      let y-style = get-axis-style(ptx, style, y.name)
      let u-style = get-axis-style(ptx, style, u.name)
      let v-style = get-axis-style(ptx, style, v.name)

      let (x-low, x-high, y-low, y-high) = (xy-proj.transform)(
        (x.min, y.min), (x.max, y.min),
        (x.min, y.min), (x.min, y.max),
      )
      let (u-low, u-high, v-low, v-high) = (uv-proj.transform)(
        (u.min, v.max), (u.max, v.max),
        (u.max, v.min), (u.max, v.max),
      )

      let move-vec(v, direction, length) = {
        vector.add(v, direction.enumerate().map(((i, v)) => v * length.at(i)))
      }

      // Outset axes
      x-low = move-vec(x-low, (0, -1), x-style.padding)
      x-high = move-vec(x-high, (0, -1), x-style.padding)
      y-low = move-vec(y-low, (-1, 0), y-style.padding)
      y-high = move-vec(y-high, (-1, 0), y-style.padding)
      u-low = move-vec(u-low, (0, 1), u-style.padding)
      u-high = move-vec(u-high, (0, 1), u-style.padding)
      v-low = move-vec(v-low, (1, 0), v-style.padding)
      v-high = move-vec(v-high, (1, 0), v-style.padding)

      // Frame corners (FIX for uv axes)
      let south-west = move-vec(x-low, (-1, 0), x-style.padding)
      let south-east = move-vec(x-high, (+1, 0), x-style.padding)
      let north-west = move-vec(u-low, (-1, 0), u-style.padding)
      let north-east = move-vec(u-high, (+1, 0), u-style.padding)

      // Grid lengths
      let x-grid-length = u-low.at(1) - x-low.at(1)
      let y-grid-length = v-low.at(0) - y-low.at(0)
      let u-grid-length = x-low.at(1) - u-low.at(1)
      let v-grid-length = y-low.at(0) - v-low.at(0)

      let axes = (
        (x, (0,+1), (0,x-grid-length), cartesian-axis-projection(x, x-low, x-high), x-style, false),
        (y, (+1,0), (y-grid-length,0), cartesian-axis-projection(y, y-low, y-high), y-style, false),
        (u, (0,-1), (0,u-grid-length), cartesian-axis-projection(u, u-low, u-high), u-style, not has-uv),
        (v, (-1,0), (v-grid-length,0), cartesian-axis-projection(v, v-low, v-high), v-style, not has-uv),
      )

      draw.group(name: "spine", {
        for (ax, dir, grid-dir, proj, style, mirror) in axes {
          draw.on-layer(style.axis-layer, {
            draw.line(proj(ax.min), proj(ax.max), stroke: style.stroke, mark: style.mark)
          })
          if "computed-ticks" in ax {
            if not mirror {
              ticks.draw-cartesian-grid(proj, grid-dir, ax, ax.computed-ticks, style)
            }
            ticks.draw-cartesian(proj, dir, ax.computed-ticks, style, is-mirror: mirror)
          }
        }
      })

      // TODO: Draw labels
    },
  )
}
