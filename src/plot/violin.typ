#import "line.typ"

#let kernal-normal(x, stdev: 1.5) = {
  (1/calc.sqrt(2*calc.pi*calc.pow(stdev,2))) * calc.exp( - (x*x)/(2*calc.pow(stdev,2)))
}

#let violin( 
  data,
  x-key: 0,
  y-key: 1,
  side: "left", // "left", "right", "both"
  style: (:),
  kernel: kernal-normal.with(stdev: 1.5),
  bandwidth: 1,
  extend: 0.5,
  axes: ("x", "y"),
) = {

  for category in data {
    let (x, ys) = (category.at(x-key), category.at(y-key))
    let n = ys.len()
    let (min, max) = (calc.min(..ys), calc.max(..ys))
    let domain = (min - (max - min)*extend, max + (max - min)*extend)

    let convolve = (t, side: side)=>{
      let val = ys.map((y)=>kernel((y - t)/bandwidth)).sum()
      (x + (1/(n*bandwidth) * val) * if side == "left" {-1} else {1}, t)
    }

    if (side in ("left", "both")) {
      line.add(
        convolve.with(side: "left"),
        domain: domain,
        line: "raw",
        fill-type: "shape",
        fill: true,
        style: style
      )
    }

    if (side in ("right", "both")){
      line.add(
        convolve.with(side: "right"),
        domain: domain,
        line: "raw",
        fill-type: "shape",
        fill: true,
        style: style
      )
    }


  }

}