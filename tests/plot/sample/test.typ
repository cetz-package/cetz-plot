#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#let f(n) = {
  assert(type(n) == int)
  range(1, n+1).map(n => calc.pow(1/3, n)).sum(default: 0)
}

// Sample integer values
#test-case({
  plot.plot(size: (3, 3), x-tick-step: none, y-tick-step: none,
  {
    plot.add(domain: (0, 7), samples: "INT", f, mark: "x")
  })
})

// Take samples at specific points
#test-case({
  plot.plot(size: (3, 3), x-tick-step: none, y-tick-step: none,
  {
    plot.add(domain: (0, 1), samples: 2, x => x, mark: "x",
      sample-at: (.1, .2, .3))
  })
})
