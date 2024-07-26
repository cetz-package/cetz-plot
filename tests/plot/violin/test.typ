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
  {
    let vals = (5,4,6,8,5,4,1,5,5,5,4,2,5,4,6,5,4,5,8,4,5,)
    cetz-plot.plot.add(vals.map(it=>(0,it)), mark: "x", style: (stroke: none))
    cetz-plot.plot.violin(vals)
  })
})
