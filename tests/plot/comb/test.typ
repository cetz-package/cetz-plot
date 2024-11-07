#set page(width: auto, height: auto)
#import "/src/cetz.typ": *
#import "/src/lib.typ": *
#import "/tests/helper.typ": *

#let data = csv("testdata.csv").map(
  ((x, y,..))=>{
    (
      float(x), 
      float(y), 
      if x in ("41",) {
        (stroke: (paint: red))
      } else if x in ("93",){
        (stroke: (paint: blue))
      },
    )
  }
)

= General case
- Input data is an array of the form (mz, int, ..)
- keys are not explicitly set.
- X, Y ranges not set

#test-case({
  plot.plot(
    size: (10,6), 
    // y-max: 100,
    // x-min: 0, x-max: 175,
    {
      plot.add-comb(
        label: "Linalool, 70eV",
        // style-key: 2,
        // style: (stroke: (paint: black)),
        data
      )
    }
  )
})


= With domain set
- General case, but X Y domains are defined explicitly and without mistake

#table(
  columns: 3,
  ..(for i in range(0, 9) {
    let (x,y) = (calc.div-euclid(i, 3),calc.rem-euclid(i, 3))
    (table.cell( x: x, y: 3-y, test-case({
      plot.plot(
        x-label: none, y-label: none,
        x-tick-step: none, y-tick-step: none,
        size: (3,3), 
        x-min: x * 50, x-max: (x+1) * 50,
        y-min: y * 33, y-max: (y+1) * 33,
        {
          plot.add-comb(
            data
          )
        }
      )
    })),)
  })
)

= With uniform style
Applying the same style to the whole series

#test-case({
  plot.plot(
    size: (10,6), 
    // y-max: 100,
    // x-min: 0, x-max: 175,
    {
      plot.add-comb(
        label: "Linalool, 70eV",
        // style-key: 2,
        style: (stroke: (paint: black, dash: "dashed")),
        data
      )
    }
  )
})

= With uniform style and individual style
Applying the same style across a whole series, except for some for which it is defined explicitly\ as a field set by `style-key`

#test-case({
  plot.plot(
    size: (10,6), 
    // y-max: 100,
    // x-min: 0, x-max: 175,
    {
      plot.add-comb(
        label: "Linalool, 70eV",
        style-key: 2,
        style: (stroke: (paint: black, dash: "dashed")),
        data
      )
    }
  )
})

= With Marks
Uniform marks across the series

#test-case({
  plot.plot(
    size: (10,6), 
    // y-max: 100,
    x-min: 35, x-max: 45,
    {
      plot.add-comb(
        label: "Linalool, 70eV",
        mark: "-",
        mark-size: 0.2,
        data
      )
      // plot.add(domain: (0, 100), x=>x, mark: "x")
    }
  )
})

= Axis swap
// Test pending upstream
#test-case({
  plot.plot(
    size: (10,6), 
    y-max: 0, y-min: 180,
    // x-min: 35, x-max: 45,
    {
      plot.add-comb(
        axes: ("y", "x"),
        label: "Linalool, 70eV",
        // mark: "-",
        mark-size: 0.2,
        data
      )
      // plot.add(domain: (0, 100), x=>x, mark: "x")
    }
  )
})

= Logarithym
// Test pending upstream
#test-case({
  plot.plot(
    size: (10,6), 
    // x-min: 35, x-max: 45,
    y-max: 100,
    y-mode: "log", y-tick-step: 1, y-base: 10, y-format: "sci", y-minor-tick-step: 1,
    {
      plot.add-comb(
        label: "Linalool, 70eV",
        mark: "o",
        mark-size: 0.2,
        data
      )
      // plot.add(domain: (0, 100), x=>x, mark: "x")
    }
  )
})

#test-case({
  plot.plot(
    size: (10,6), 
    x-min: 10, x-max: 1000,
    y-max: 100, y-tick-step: 20,
    x-mode: "log", x-tick-step: 1, x-base: 10, x-format: "sci",
    {
      plot.add-comb(
        label: "Linalool, 70eV",
        mark: "x",
        mark-size: 0.2,
        data
      )
    }
  )
})