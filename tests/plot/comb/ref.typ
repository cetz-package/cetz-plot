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
      // plot.add-comb(
      //   label: "Linalool, 70eV",
      //   mark: "x",
      //   mark-size: 0.1,
        
      //   data
      // )
      plot.add(domain: (0, 100), x=>x, mark: "x")
    }
  )
})