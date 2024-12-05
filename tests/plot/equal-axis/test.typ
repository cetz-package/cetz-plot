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
    plot.lin-axis("a")
    plot.lin-axis("b")
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
    plot.lin-axis("a")
    plot.lin-axis("b")
    plot.add(domain: (0, 2 * calc.pi), t => (calc.cos(t), calc.sin(t)))
    plot.add(domain: (0, 2 * calc.pi), t => (calc.cos(t), calc.sin(t)),
      axes: ("a", "b"))
  })
})
