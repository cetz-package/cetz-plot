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

= Introduction <ch:intro>

CeTZ-Plot is a package for making plots in Typst using CeTZ. 

= Usage <ch:usage>

This is the minimal starting point:
#pad(left: 1em)[```typ
#import "@preview/cetz:0.2.2"
#import "@preview/cetz-plot:0.1.0"
#cetz.canvas({
  import cetz.draw: *
  import cetz-plot: *
  ...
})
```]

Note that plot functions are imported inside the scope of the `canvas` block. All following example code is expected to be inside a `canvas` block, with the `cetz-plot` module imported into the namespace.

= Plot


= Chart