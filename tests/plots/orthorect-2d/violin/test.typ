#set page(width: auto, height: auto, margin: 1cm)
#import "/tests/helper.typ": *

#test-case({

  let vals = (
    (0,(5,4,6,8,5.1,4.1,1,5.2,5.3,5.4,4.2,2,5.5,4.3,6,5,4,5,8,4,5,)),
    (1,(5,4,6,8,5.1,4.1,1,5.2,5.3,5.4,4.2,2,5.5,4.3,6,5,4,5,8,4,5,)),
    (2,(5,4,6,8,5.1,4.1,1,5.2,5.3,5.4,4.2,2,5.5,4.3,6,5,4,5,8,4,5,)),
  )

  cetz-plot.plot(
    size: (9, 6),
    
    y-label: [Age],
    y-min: -10, y-max: 20,
    y-tick-step: 10, y-minor-tick-step: 5,
    y-grid: "major",

    x-label: [Class],
    x-min: -0.5, x-max: 2.5,
    x-tick-step: none,
    x-ticks: ( (0, [First]), (1, [Second]), (2, [Third])),
    {
      cetz-plot.add.violin(
        vals,
        extents: 0.5,
        side: "left",
        bandwidth: 0.45,
        label: [Male],
      )

      cetz-plot.add.violin(
        vals,
        extents: 0.5,
        side: "right",
        bandwidth: 0.5,
        label: [Female]
      )
    }
  )

})