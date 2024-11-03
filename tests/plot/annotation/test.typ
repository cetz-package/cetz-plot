#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#test-case({
  import draw: *
  set-style(rect: (stroke: none))

  plot.plot(size: (6, 4), {
    plot.add(domain: (-calc.pi, 3*calc.pi), calc.sin)
    plot.annotate(background: true, {
      rect((0, -1),       (calc.pi, 1), fill: blue.lighten(90%))
      rect((calc.pi, -1.1), (2*calc.pi, 1.1), fill: red.lighten(90%))
      rect((2*calc.pi, -1.5), (3.5*calc.pi, 1.5), fill: green.lighten(90%))
    })
    plot.annotate(padding: .1, {
      line((calc.pi / 2, 1.1), (rel: (0, .2)), (rel: (2*calc.pi, 0)), (rel: (0, -.2)))
      content((calc.pi * 1.5, 1.5), $ lambda $)
    })
    plot.annotate(padding: .1, {
      line((calc.pi / 2,-.1), (calc.pi / 2, .8), mark: (end: "stealth"))
    })
  })
})

#test-case({
  import draw: *
  set-style(rect: (stroke: none))

  plot.plot(size: (6, 4), x-horizontal: false, y-horizontal: true, {
    plot.add(domain: (-calc.pi, 3*calc.pi), calc.sin)
    plot.annotate(background: true, {
      rect((0, -1),       (calc.pi, 1), fill: blue.lighten(90%))
      rect((calc.pi, -1.1), (2*calc.pi, 1.1), fill: red.lighten(90%))
      rect((2*calc.pi, -1.5), (3.5*calc.pi, 1.5), fill: green.lighten(90%))
    })
    plot.annotate(padding: .1, {
      line((calc.pi / 2, 1.1), (rel: (0, .2)), (rel: (2*calc.pi, 0)), (rel: (0, -.2)))
      content((calc.pi * 1.5, 1.5), $ lambda $)
    })
    plot.annotate(padding: .1, {
      line((calc.pi / 2,-.1), (calc.pi / 2, .8), mark: (end: "stealth"))
    })
  })
})

#test-case({
  import draw: *
  set-style(rect: (stroke: none))

  plot.plot(size: (6, 4), x-tick-step: 1, {
    plot.add(domain: (100, 101), calc.sin)
    plot.annotate(padding: .1, {
      content( (101.5, 0), [A])
    })
  })
})