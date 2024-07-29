#import "/src/lib.typ" as cetz-plot

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

  block(
    place(
      top + left,
      dx: -left-fringe * 22cm + 5mm,
      text(3cm, right-color)[CeTZ]
    ) +
    text(3cm)[Plot]
  )
  block(
    v(1cm) +
    text(
      20pt,
      authors.map(v => link(v.at(1), [#v.at(0)])).join("\n")
    )
  )
  block(
    v(2cm) +
    text(
      20pt,
      link(
        url,
        [Version ] + [#cetz-plot.version]
      )
    )
  )
  pagebreak(weak: true)
}
