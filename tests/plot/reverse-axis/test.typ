#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#test-case({
  plot.plot(size: (10, 10), x-min: 9, x-max: 0,
  {
    plot.add(domain: (0, 9), calc.sqrt)
  })
})

#test-case({
  plot.plot(size: (10, 10), y-min: 9, y-max: 0,
  {
    plot.add(domain: (-5, 5), x => calc.pow(x, 2))
  })
})
