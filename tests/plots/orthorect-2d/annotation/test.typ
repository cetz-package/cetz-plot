#set page(width: auto, height: auto, margin: 1cm)
#import "/tests/helper.typ": *

#test-case({
  cetz.draw.set-style(rect: (stroke: none))

  cetz-plot.plot(size: (6, 4), {
    cetz-plot.add.xy(domain: (-calc.pi, 3*calc.pi), calc.sin, samples: 100)
    cetz-plot.add.annotation(background: true, {
      cetz.draw.rect((0, -1),       (calc.pi, 1), fill: blue.lighten(90%))
      cetz.draw.rect((calc.pi, -1.1), (2*calc.pi, 1.1), fill: red.lighten(90%))
      cetz.draw.rect((2*calc.pi, -1.5), (3.5*calc.pi, 1.5), fill: green.lighten(90%))
    })
    cetz-plot.add.annotation(padding: .1, {
      cetz.draw.line((calc.pi / 2, 1.1), (rel: (0, .2)), (rel: (2*calc.pi, 0)), (rel: (0, -.2)))
      cetz.draw.content((calc.pi * 1.5, 1.5), $ lambda $)
    })
    cetz-plot.add.annotation(padding: .1, {
      cetz.draw.line((calc.pi / 2,-.1), (calc.pi / 2, .8), mark: (end: "stealth"))
    })
  })
})