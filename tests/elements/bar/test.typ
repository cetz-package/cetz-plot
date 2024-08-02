#set page(width: auto, height: auto, margin: 1cm)
#import "/tests/helper.typ": *

#test-case({

  // Sample function manually
  let data = (
    (0, 100, 20),
    (1, 75, 15),
    (2, 75, 10),
    (3, 75, 50),
    (4, 75),
    (5, 75),
    (6, 75),
  )

  cetz-plot.plot(
    axis-style: cetz-plot.axis-style.orthorect-2d,
    size: (12,7),

    x-tick-step: none,
    // y-min: 50,
    // y-max: 105,
    x-ticks: ((0, [My Bar]),),
    {

      cetz-plot.add.bar(
        data, 
        y-base-key: 2,
        label: [Hello],
      )

    }
  )

})

