#set page(width: auto, height: auto)
#import "/src/lib.typ": *
#import "/src/cetz.typ": *
#import "/tests/helper.typ": *

/* Empty plot */
#test-case({
  import draw: *

  draw.set-style(
    axes: (
      stroke: 0.55pt,
      tick: (
        stroke: 0.5pt,
      )
    ),
    legend: (
      stroke: none,
    )
  )

  let default-colors = (palette.blue-colors.at(3), palette.pink-colors.at(3))

  plot.plot(size: (9, 6),
    
    y-label: [Age],
    y-min: -10, y-max: 20,

    x-label: [Class],
    x-min: -0.5, x-max: 2.5,
    x-tick-step: none,
    x-ticks: ( (0, [First]), (1, [Second]), (2, [Third])),

    plot-style: (i) => {
      let color = default-colors.at(calc.rem(i, default-colors.len()))
      (stroke: color + 0.75pt, fill: color.lighten(75%))
    },
  {
    let vals = (
      (0,(5,4,6,8,5.1,4.1,1,5.2,5.3,5.4,4.2,2,5.5,4.3,6,5,4,5,8,4,5,)),
      (1,(5,4,6,8,5.1,4.1,1,5.2,5.3,5.4,4.2,2,5.5,4.3,6,5,4,5,8,4,5,)),
      (2,(5,4,6,8,5.1,4.1,1,5.2,5.3,5.4,4.2,2,5.5,4.3,6,5,4,5,8,4,5,)),
    )

    cetz-plot.plot.violin(
      vals,
      extents: 0.5,
      side: "left",
      bandwidth: 0.45,
      label: [Male],
    )

    cetz-plot.plot.violin(
      vals,
      extents: 0.5,
      side: "right",
      bandwidth: 0.5,
      label: [Female]
    )
  })
})