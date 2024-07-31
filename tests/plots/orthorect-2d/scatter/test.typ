#set page(width: auto, height: auto)
#import "/tests/helper.typ": *

#test-case({
  cetz-plot.plot(
    axis-style: cetz-plot.orthorect-2d,
    x-min: 0, x-max: 1,
    y-min: 0, y-max: 1,
    {
      cetz.plot.add((x)=>x, domain: (0,1))
    }
  )
})