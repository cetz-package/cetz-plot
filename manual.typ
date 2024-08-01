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
  outline(indent: true, depth: 3)
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
  cetz-plot.plot(...,{

  })
})
```]

Note that plot functions are imported inside the scope of the `canvas` block. All following example code is expected to be inside a `canvas` block, with the `cetz-plot` module imported into the namespace.

= Plot

#doc-style.parse-show-module("/src/plot.typ", first-heading-level: 1)

To draw elements insides a plot, using the plots coordinate system, use
the `plot.annotate(..)` function.

=== Options

You can use the following options to customize each axis of the plot. You must pass them as named arguments prefixed by the axis name followed by a dash (`-`) they should target. Example: `x-min: 0`, `y-ticks: (..)` or `x2-label: [..]`.

#doc-style.show-parameter-block("label", ("none", "content"), default: none)[
  The axis' label. If and where the label is drawn depends on the `axis-style`.
  #example(```
  cetz-plot.plot(
    size: (5,5), 
    x-label: [My $x$-label],
    y-label: [Intensity [$"cts"$]],
    {
      cetz-plot.add.xy(
        domain: (0, 2 * calc.pi), 
        t => (calc.cos(t), calc.sin(t))
      )
    }
  )
  ```)
]

#doc-style.show-parameter-block("min", ("auto", "float"), default: auto)[
  Axis lower domain value. If this is set greater than than `max`, the axis' direction is swapped
    #example(```
  cetz-plot.plot(
    size: (5,5), 
    x-min: -5, x-max: 5,
    y-min: -2,
    {
      cetz-plot.add.xy(
        domain: (0, 2 * calc.pi), 
        t => (calc.cos(t), calc.sin(t))
      )
    }
  )
  ```)
]

#doc-style.show-parameter-block("max", ("auto", "float"), default: auto)[
  Axis upper domain value. If this is set to a lower value than `min`, the axis' direction is swapped
]

#doc-style.show-parameter-block("equal", ("string"), default: none)[
  Set the axis domain to keep a fixed aspect ratio by multiplying the other axis domain by the plots aspect ratio,
  depending on the other axis orientation (see `horizontal`).
  This can be useful to force one axis to grow or shrink with another one.
  You can only "lock" two axes of different orientations.
  #example(```
  cetz-plot.plot(
    size: (5,2.5), 
    x-tick-step: 1, y-tick-step: 1,
    x-equal: "y",
    {
      cetz-plot.add.xy(
        domain: (0, 2 * calc.pi), 
        t => (calc.cos(t), calc.sin(t))
      )
    }
  )
  ```)
]

#doc-style.show-parameter-block("horizontal", ("bool"), default: "axis name dependant")[
  If true, the axis is considered an axis that gets drawn horizontally, vertically otherwise.
  The default value depends on the axis name on axis creation. Axes which name start with `x` have this
  set to `true`, all others have it set to `false`. Each plot has to use one horizontal and one
  vertical axis for plotting, a combination of two y-axes will panic: ("y", "y2").
]

#doc-style.show-parameter-block("tick-step", ("none", "auto", "float"), default: auto)[
  The increment between tick marks on the axis. If set to `auto`, an
  increment is determined. When set to `none`, incrementing tick marks are disabled.
]

#doc-style.show-parameter-block("minor-tick-step", ("none", "float"), default: none)[
  Like `tick-step`, but for minor tick marks. In contrast to ticks, minor ticks do not have labels.
]

#doc-style.show-parameter-block("ticks", ("none", "array"), default: none)[
  A List of custom tick marks to additionally draw along the axis. They can be passed as
  an array of `<float>` values or an array of `(<float>, <content>)` tuples for
  setting custom tick mark labels per mark.

  #example(```
  cetz-plot.plot(
    x-min: 0, x-max: 4,
    x-tick-step: none, 
    x-ticks: (1, 2, 3),

    y-min: 1, y-max: 2,
    y-tick-step: none,
    y-ticks: ((1, [One]), (2, [Two])),
    {
      cetz-plot.add.xy(((0,0),))
    }
  )
  ```)

  Examples: `(1, 2, 3)` or `((1, [One]), (2, [Two]), (3, [Three]))`
]

#doc-style.show-parameter-block("format", ("none", "string", "function"), default: "float")[
  How to format the tick label: You can give a function that takes a `<float>` and return
  `<content>` to use as the tick label. You can also give one of the predefined options:
  / float: Floating point formatting rounded to two digits after the point (see `decimals`)
  / sci: Scientific formatting with $times 10^n$ used as exponet syntax

  #example(```
  let formatter(v) = if v != 0 {
    $ #{v/calc.pi} pi $
  } else {
    $ 0 $
  }

  cetz-plot.plot(
    x-tick-step: calc.pi, 
    x-min: 0, x-max: 2 * calc.pi,
    x-format: formatter,
  {
    cetz-plot.add.xy(((0,0),))
  })
  ```)
]

#doc-style.show-parameter-block("decimals", ("int"), default: 2, [
  Number of decimals digits to display for tick labels, if the format is set
  to `"float"`.
])

#doc-style.show-parameter-block("unit", ("none", "content"), default: none)[
  Suffix to append to all tick labels.
]

#doc-style.show-parameter-block("mode", ("none", "string"), default: none)[
  The scaling function of the axis. Takes `lin` (default) for linear scaling,
  and `log` for logarithmic scaling.
]

#doc-style.show-parameter-block("base", ("none", "number"), default: none)[
  The base to be used when labeling axis ticks in logarithmic scaling
]

#doc-style.show-parameter-block("grid", ("bool", "string"), default: false)[
  If `true` or `"major"`, show grid lines for all major ticks. If set
  to `"minor"`, show grid lines for minor ticks only.
  The value `"both"` enables grid lines for both, major- and minor ticks.

  #example(```
  cetz-plot.plot(
    x-min: 0, x-max: 2, x-grid: "both",
    x-tick-step: 1,

    y-min: 0, y-max: 2, y-grid: "both",
    y-tick-step: 1, y-minor-tick-step: .2, 
    {
      cetz-plot.add.xy(((0,0),))

    }
  )
  ```)
]

#doc-style.show-parameter-block("break", ("bool"), default: false)[
  If true, add a "sawtooth" at the start or end of the axis line, depending
  on the axis bounds. If the axis min. value is > 0, a sawtooth is added
  to the start of the axes, if the axis max. value is < 0, a sawtooth is added
  to its end.
]

// = Chart