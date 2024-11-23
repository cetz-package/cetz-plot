#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#let data = (
  ([Category A], 10),
  ([Category B], 20),
  ([Category C], 30),
)

#test-case(args => {
  chart.pyramid(
    data,
    value-key: 1,
    label-key: 0,
    side-label: (content: (value, label) => [#value%]),
    mode: args.mode
  )
}, args: (
  (mode: "REGULAR"),
  (mode: "AREA-HEIGHT"),
  (mode: "HEIGHT"),
  (mode: "WIDTH"),
))
