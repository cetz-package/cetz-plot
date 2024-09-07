#import "/src/lib.typ" as cetz-plot
#import "/src/cetz.typ"

/// Make the title-page
#let make-title() = {
  let left-fringe = 39%
  let left-color = rgb(140,90,255).darken(30%)
  let right-color = white

  let url = "https://github.com/cetz-package/cetz-plot"
  let authors = (
    ([Johannes Wolf], "https://github.com/johannes-wolf"),
    ([fenjalien],     "https://github.com/fenjalien"),
  )

  set page(
    numbering: none,
    background: place(
      top + left,
      rect(
        width: left-fringe,
        height: 100%,
        fill: left-color
      )
    ),
    margin: (
      left: left-fringe * 22cm,
      top: 12% * 29cm
    ),
    header: none,
    footer: none
  )

  set text(weight: "bold", left-color)
  show link: set text(left-color)

  block({
    place(
      top + left,
      dx: -left-fringe * 22cm + 5mm,
      text(3cm, right-color)[CeTZ]
    )
    text(3cm)[Plot]
  })

  block({
    v(1cm)
    text(
      20pt,
      authors.map(v => link(v.at(1), [#v.at(0)])).join("\n")
    )
  })
  block({
    v(2cm)
    text(
      20pt,
      link(
        url,
        [Version ] + [#cetz-plot.version]
      )
    )
  })

  block({
    v(2cm)
    set text(fill: black)
    cetz.canvas({
      cetz-plot.plot(
        size: (8,5),
        x-tick-step: calc.pi / 4,
        x-minor-tick-step: calc.pi / 16,
        x-grid: "both",
        x-min: 0, x-max: 2 * calc.pi,
        x-format: cetz-plot.axes.format.multiple-of,

        y-min: -1, y-max: 1, y-tick-step: 0.5, y-minor-tick-step: 0.1,
        y-grid: "both",
        {
          cetz-plot.add.xy(
            calc.sin, 
            domain: (0,2*calc.pi), 
            label: $y=x$, 
            line: "raw",
            samples: 100,
            epigraph: true,
          )

          cetz-plot.add.xy(
            (t)=>calc.pow(calc.sin(t),2),
            domain: (0, 2* calc.pi), 
            line: "raw",
            samples: 100,
            hypograph: true,
            label: $sin^2 (x)$
          )
        }
      )
    })
  })

  pagebreak(weak: true)
}
