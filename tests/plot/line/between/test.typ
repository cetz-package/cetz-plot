#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#let size = (6, 4)
#let f(x, y: 0) = y + calc.sin(x * 1deg)

/* Fill between */
#test-case({
  import draw: *

  plot.plot(size: size,
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add-fill-between(domain: (-360, 360), f.with(y: -1), f.with(y: 1))
    })
})

/* Fill between - Clip Top */
#test-case({
  import draw: *

  plot.plot(size: size,
    x-tick-step: none,
    y-tick-step: none,
    y-max: .5,
    {
      plot.add-fill-between(domain: (-360, 360), f.with(y: -1), f.with(y: 1))
    })
})

/* Fill between - Clip Bottom */
#test-case({
  import draw: *

  plot.plot(size: size,
    x-tick-step: none,
    y-tick-step: none,
    y-min: -.5,
    {
      plot.add-fill-between(domain: (-360, 360), f.with(y: -1), f.with(y: 1))
    })
})

/* Fill between - Clip Top & Bottom */
#test-case({
  import draw: *

  plot.plot(size: size,
    x-tick-step: none,
    y-tick-step: none,
    y-max: .5,
    y-min: -.5,
    {
      plot.add-fill-between(domain: (-360, 360), f.with(y: -1), f.with(y: 1))
    })
})

/* Fill between - Test 2 */
#test-case({
  import draw: *

  plot.plot(size: size,
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add-fill-between(domain: (0, 2 * calc.pi),
        t => (calc.cos(t) * 1.5, calc.sin(t)),
        t => (calc.cos(t), calc.sin(t) * 1.5))
    })
})

/* Fill between - Test 3 */
#test-case({
  import draw: *

  plot.plot(size: size,
    x-tick-step: none,
    y-tick-step: none,
    {
      plot.add-fill-between(domain: (0, 2 * calc.pi),
        t => (calc.cos(t) * 1.5, calc.sin(t) * 1.5),
        t => (calc.cos(t), calc.sin(t)))
    })
})

/* Fill between - Test 4 */
#test-case({
  import draw: *

  let f(x) = calc.sin(x) + calc.cos(3 * x)

  plot.plot(size: size,
    x-tick-step: none,
    y-tick-step: none,
    {
      // Function
      plot.add(domain: (0, 4 * calc.pi), f)
      // Error-Band fill
      plot.add-fill-between(domain: (0, 4 * calc.pi),
        style: (stroke: none),
        x => f(x) - calc.exp(x/4) / 2,
        x => f(x) + calc.exp(x/4) / 2)
    })
})
