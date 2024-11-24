#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#test-case({
  import draw: *

  plot.plot(size: (6,3),
    x-tick-step: none,
    y-tick-step: none,
    x-equal: "y",
    b-equal: "a",
  {
    plot.add-cartesian-axis("a", (0,0), (6,0))
    plot.add-cartesian-axis("b", (0,0), (0,3))
    plot.add(domain: (0, 2 * calc.pi), t => (calc.cos(t), calc.sin(t)))
    plot.add(domain: (0, 2 * calc.pi), t => (calc.cos(t), calc.sin(t)),
      axes: ("a", "b"))
  })
})

#test-case({
  import draw: *

  plot.plot(size: (3,6),
    x-tick-step: none,
    y-tick-step: none,
    x-equal: "y",
    b-equal: "a",
  {
    plot.add-cartesian-axis("a", (0,0), (3,0))
    plot.add-cartesian-axis("b", (0,0), (0,6))
    plot.add(domain: (0, 2 * calc.pi), t => (calc.cos(t), calc.sin(t)))
    plot.add(domain: (0, 2 * calc.pi), t => (calc.cos(t), calc.sin(t)),
      axes: ("a", "b"))
  })
})
