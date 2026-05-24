#set page(width: auto, height: auto)
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#let labels = (
  [A],
  [B],
  [C],
  [D],
  [E],
)

#test-case({
  chart.radarchart(
    labels,
    (0.3, 1, 0.3, 0.8, 0.8),
  )
})

#test-case({
  chart.radarchart(
    labels,
    (
      (0.3, 1, 0.3, 0.8, 0.8),
      (0.9, 0.3, 0.9, 0.5, 0.5),
      (0.6, 0.5, 0, 0.5, 0.1),
    ),
    radius: 3,
    web-label-offset: 0.6,
    web-ticks: 3,
    data-style: (
      blue.transparentize(30%),
      red.transparentize(30%),
      green.transparentize(30%),
    ),
  )
})
