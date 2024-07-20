#import "/doc/util.typ": *
#import "/doc/example.typ": example
#import "/doc/style.typ" as doc-style
#import "/src/lib.typ": *
#import "/src/cetz.typ": *
#import "@preview/tidy:0.2.0"


// Usage:
//   ```example
//   /* canvas drawing code */
//   ```
#show raw.where(lang: "example"): example
#show raw.where(lang: "example-vertical"): example.with(vertical: true)

#make-title()

#set terms(indent: 1em)
#set par(justify: true)
#set heading(numbering: (..num) => if num.pos().len() < 4 {
    numbering("1.1", ..num)
  })
#show link: set text(blue)

// Outline
#{
  show heading: none
  columns(2, outline(indent: true, depth: 3))
  pagebreak(weak: true)
}

#set page(numbering: "1/1", header: align(right)[CeTZ-Plot])

= Plot

#doc-style.parse-show-module("/src/plot.typ")
#for m in ("line", "bar", "boxwhisker", "contour", "errorbar", "annotation", "formats") {
  doc-style.parse-show-module("/src/plot/" + m + ".typ")
}

= Chart

#doc-style.parse-show-module("/src/chart.typ")
#for m in ("barchart", "boxwhisker", "columnchart", "piechart") {
  doc-style.parse-show-module("/src/chart/" + m + ".typ")
}
