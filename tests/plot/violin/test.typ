#set page(width: auto, height: auto)
#import "/src/lib.typ": *
#import "/src/cetz.typ": *
#import "/tests/helper.typ": *

/* Empty plot */
#test-case({
  import draw: *

  plot.plot(size: (9, 6),
    // x-tick-step: none,
    // y-tick-step: none,
    y-min: -10, y-max: 20,
    x-min: -1, x-max: 2,
  {
    let vals = (
      (0,(5,4,6,8,5.1,4.1,1,5.2,5.3,5.4,4.2,2,5.5,4.3,6,5,4,5,8,4,5,)),
      (1,(5,4,6,8,5.1,4.1,1,5.2,5.3,5.4,4.2,2,5.5,4.3,6,5,4,5,8,4,5,)),
    )
    // for (x, ys) in vals {
    //   cetz-plot.plot.add(ys.map(y=>(x,y)), mark: "x", style: (stroke: none))
    // }
    cetz-plot.plot.violin(
      vals,
      extend: 0.35,
      side: "right",
      bandwidth: 0.5
    )
  })
})
