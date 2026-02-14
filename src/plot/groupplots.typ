
import "/src/cetz.typ"

/// Create a group of plots.
///
/// This function allows arranging multiple plots in a grid layout.
/// It takes a variable number of arguments, alternating between options (dictionary) and plot content (body).
///
/// == Options
///
/// - columns (int): Number of columns in the grid.
/// - size (array): Size of each plot `(width, height)`.
/// - rows (auto, int): Number of rows. If `auto`, calculated from number of plots and columns.
/// - horizontal-sep (float): Horizontal separation between plots.
/// - vertical-sep (float): Vertical separation between plots.
/// - title (none, string, content): Global title for the group of plots.
/// - sublabels (none, string): Numbering pattern for sublabels (e.g., "(a)").
/// - ..options (any): Default options passed to every plot.
/// - ..cont (any): Alternating plot options (dictionary) and plot content (body).
///
/// == Example
///
/// ```typst
/// groupplots(
///   3, (4, 4),
///   horizontal-sep: 1.5, vertical-sep: 1.5,
///   (title: "Plot 1"), { plot.add(...) },
///   (title: "Plot 2"), { plot.add(...) }
/// )
/// ```
#let groupplots(
  columns, 
  size, 
  rows: auto, 
  horizontal-sep: 1,
  vertical-sep: 1,
  title: none, 
  sublabels: none,
  group-style: (:),
  ..options
) = {
  import "/src/plot.typ" as plot_mod
  import "/src/cetz.typ"

  let default-params = options.named()
  default-params.insert("size", size)
  
  let cont = options.pos()

  assert(cont.len() > 0, message: "No plots provided to groupplots.")
  assert(calc.rem(cont.len(), 2) == 0, message: "groupplots expects alternating options and body arguments.")

  let plot-items = ()
  let plot-titles = () // Keep track of titles for sublabels matching if needed, though plot handles its own title now.
  let has-xlabel = false

  for i in range(0, cont.len(), step: 2) {
    let plot-args = cont.at(i)
    let plot-content = cont.at(i + 1)
    
    if type(plot-args) != dictionary {
       if plot-args == () {
         plot-args = (:)
       } else {
         panic("Expected a dictionary or empty array for plot arguments at index " + str(i) + ", found " + type(plot-args))
       }
    }

    let merged-args = default-params + plot-args

    if "x-label" in merged-args and merged-args.at("x-label") != none {
      has-xlabel = true
    }
    
    if plot-content != none {
      plot-items.push(plot_mod.plot(..merged-args, plot-content))
    }
  }

  let n = plot-items.len()
  let grid-rows = if rows == auto { calc.ceil(n / columns) } else { rows }
  let (plot-width, plot-height) = size

  cetz.draw.group(name: "groupplots", {
    if title != none {
      let total-width = columns * plot-width + (columns - 1) * horizontal-sep
      cetz.draw.content((total-width / 2, plot-height + 1), text(weight: "bold", title), anchor: "south")
    }

    for j in range(0, n) {
      let col = calc.rem(j, columns)
      let row = calc.floor(j / columns)
      
      let ox = col * (plot-width + horizontal-sep)
      let oy = -(row * (plot-height + vertical-sep))

      cetz.draw.group({
        cetz.draw.set-origin((ox, oy))
        plot-items.at(j)
        
        // Sublabels
        if sublabels != none {
          let sublabel-y = if has-xlabel { -1.0 } else { -0.5 }
          cetz.draw.content((plot-width / 2, sublabel-y), numbering(sublabels, j + 1), anchor: "north")
        }
      })
    }
  })
}
