#import "line.typ": add

#let MODELS = (
  "linear": x => (1, x),
  "quadratic": x => (1, x, calc.pow(x, 2))
)

// https://en.wikipedia.org/wiki/Gaussian_elimination#Pseudocode
// A [array of array of float, size m x m]
// b [array of float, size m]
// Return (A [array of array of float, size m x m], b [array of float, size m])
//  in row echelon form.
#let gaussian(A, b) = {
  let h = 0 // pivot row
  let k = 0 // pivot column
  let m = A.len()

  while h < m and k < m {
    // Find k-th pivot:
    let i_max = h
    for i in range(h, m) {
      if calc.abs(A.at(i).at(k)) > calc.abs(A.at(i_max).at(k)) {
        i_max = i
      }
    }

    // No pivot in this column, I guess we should abort?
    if A.at(i_max).at(k) == 0 {
      k += 1
      continue
    }

    // Swap h <=> i_max to float the pivot to the top:
    (A.at(i_max), A.at(h)) = (A.at(h), A.at(i_max))
    (b.at(i_max), b.at(h)) = (b.at(h), b.at(i_max))

    // Subtract the pivot row from the remaining rows:
    for i in range(h + 1, m) {
      let f = A.at(i).at(k) / A.at(h).at(k)
      // The entry below the pivot point is subtracted to zero:
      A.at(i).at(k) = 0
      for j in range(k + 1, m) {
        A.at(i).at(j) -= A.at(h).at(j) * f
      }
      if type(b.at(h)) == int or type(b.at(h)) == float {
        b.at(i) -= b.at(h) * f
      } else if type(b.at(h)) == array {
        for j in range(b.at(i).len()) {
          b.at(i).at(j) -= b.at(h).at(j) * f
        }
      }
    }

    h += 1
    k += 1
  }

  return (A, b)
}

// Remove right diagonal
#let rrd(A, b) = {
  let m = A.len()
  for i in range(m - 1, -1, step: -1) {
    for j in range(m - 1, i, step: -1) {
      // Subtract f * jth row from ith row to eliminate entry at column #j
      // Where f = A[i, j] / A[j, j]
      let f = A.at(i).at(j) / A.at(j).at(j)

      // Subtract row from A
      for k in range(m - 1, j - 1, step: -1) {
        A.at(i).at(k) -= f * A.at(j).at(k)
      }

      if type(b.at(i)) == int or type(b.at(i)) == float {
        b.at(i) -= f * b.at(j)
      } else if type(b.at(i)) == array {
        for k in range(0, b.at(i).len()) {
          b.at(i).at(k) -= f * b.at(j).at(k)
        }
      }
    }
  }

  return (A, b)
}

#let normalize(A, b) = {
  for i in range(A.len()) {
    let f = A.at(i).at(i)
    A.at(i).at(i) = 1

    if type(b.at(i)) == int or type(b.at(i)) == float {
      b.at(i) /= f
    } else if type(b.at(i)) == array {
      for k in range(0, b.at(i).len()) {
        b.at(i).at(k) /= f
      }
    }

  }

  return (A, b)
}

// A [array of array of float, size m x m]
#let invert(A) = {
  let m = A.len()
  let B = range(0, m).map(i => {
    let row = (0,) * m
    row.at(i) = 1
    return row
  })
  (A, B) = gaussian(A, B)
  (A, B) = rrd(A, B)
  (A, B) = normalize(A, B)
  return B
}

#let transpose(A) = {
  let out = ((0,) * A.len(),) * A.at(0).len()
  for x in range(A.len()) {
    for y in range(A.at(0).len()) {
      out.at(y).at(x) = A.at(x).at(y)
    }
  }
  return out
}

// Multiply matrices:
// A: array of array of float, size height k x width m
// B: array of array of float, size height m x width n
// return array of array of float size height k x width n
#let mmul(A, B) = {
  let k = A.len()
  let m = A.at(0).len()
  let n = -1
  if type(B.at(0)) == float or type(B) == int {
    n = 1
  } else if type(B.at(0)) == array {
    n = B.at(0).len()
  }

  if m != B.len() {
    panic("Cannot multiply array of size A(", k, " x ", m, ") and B(", B.len(), " x ", n, ")")
  }

  let out = ((0,) * n,) * k

  for x in range(k) {
    if type(B.at(0)) == float or type(B) == int {
      out.at(x).at(0) = range(m).fold(0, (sum, i) => sum + A.at(x).at(i) * B.at(i))
    } else if type(B.at(0)) == array {
      for y in range(n) {
        out.at(x).at(y) = range(m).fold(0, (sum, i) => sum + A.at(x).at(i) * B.at(i).at(y))
      }
    }
  }

  return out
}


/// Add a trend line for the given data to a plot environment.
///
/// Must be called from the body of a `plot(..)` command.
///
/// - domain (domain): Domain of `data`, if `data` is a function. Has no effect
///                    if `data` is not a function.
/// - hypograph (bool): Fill hypograph; uses the `hypograph` style key for
///                     drawing
/// - epigraph (bool): Fill epigraph; uses the `epigraph` style key for
///                    drawing
/// - fill (bool): Fill the shape of the plot
/// - fill-type (string): Fill type:
///   / `"axis"`: Fill the shape to y = 0
///   / `"shape"`: Fill the complete shape
/// - samples (int): Number of times the trend function gets called for
///   sampling y-values. This parameter gets passed to `sample-fn`.
/// - sample-at (array): Array of x-values the trend function gets sampled at in addition
///   to the default sampling. This parameter gets passed to `sample-fn`.
/// - line (string, dictionary): Line type to use. The following types are
///   supported:
///   / `"raw"`: Plot raw data
///   / `"linear"`: Linearize data
///   / `"spline"`: Calculate a Catmull-Rom curve through all points
///   / `"vh"`: Move vertical and then horizontal
///   / `"hv"`: Move horizontal and then vertical
///   / `"hvh"`: Add a vertical step in the middle
///
///   If the value is a dictionary, the type must be
///   supplied via the `type` key. The following extra
///   attributes are supported:
///   / `"samples" <int>`: Samples of splines
///   / `"tension" <float>`: Tension of splines
///   / `"mid" <float>`: Mid-Point of hvh lines (0 to 1)
///   / `"epsilon" <float>`: Linearization slope epsilon for
///      use with `"linear"`, defaults to 0.
/// - style (style): Style to use, can be used with a `palette` function
/// - axes (axes): Name of the axes to use for plotting. Reversing the axes
///   means rotating the plot by 90 degrees.
/// - mark (string): Mark symbol to place at each distinct value of the
///   graph. Uses the `mark` style key of `style` for drawing.
/// - mark-size (float): Mark size in cavas units
/// - data (array): Array of 2D data points (numeric)
///   #example(```
///   plot.plot(size: (2, 2), axis-style: none, {
///     // Using an array of points:
///     let data = ((0,0), (calc.pi/2,1), (1.5*calc.pi,-1), (2*calc.pi,0))
///     plot.add-trend(data,
///                    
///   })
///   ```)
/// - model (string, function): Which model to use for linear regression. Accepts
///   / `"linear"`: Model using $hat(y)(x) = beta_0 + beta_1 x$.
///   / `"quadratic"`: Model using $hat(y)(x) = beta_0 + beta_1 x + beta_2 x^2$.
///   / A custom model may be specified using a function of the form
///     `x => array of float` where each array is of the same size and models the
///     independent parameters at each x point
/// - label (none,content): Legend label to show for this plot.
#let add-trend(domain: auto,
               hypograph: false,
               epigraph: false,
               fill: false,
               fill-type: "axis",
               style: (:),
               mark: none,
               mark-size: .2,
               mark-style: (:),
               samples: 50,
               sample-at: (),
               line: "raw",
               axes: ("x", "y"),
               label: none,
               data,
               model
               ) = {
  if type(model) == str {
    if not MODELS.keys().contains(model) {
      panic("Unknown model ", model)
    }
    model = MODELS.at(model)
  } else if type(model) == function {
    // Calculate an example x vector to check that it is indeed a vector:
    let Xex = model(data.at(0).at(0))
    if type(Xex) == float or type(Xex) == int {
      // If it is instead simply a float, pack it in an array to avoid problems
      // with matrix operations:
      model = x => (model(x), )
    } else if type(Xex) != array {
      panic("model(", x, ") returns unusable type ", type(Xex))
    }
  } else {
    panic("Cannot use model type ", type(model))
  }

  // https://en.wikipedia.org/wiki/Linear_regression#Least-squares_estimation_and_related_techniques

  let Xmat = ()
  let Yvec = ()
  for (x, y) in data {
    Xmat.push(model(x))
    Yvec.push(y)
  }

  let beta = mmul(mmul(invert(mmul(transpose(Xmat), Xmat)), transpose(Xmat)), Yvec)

  let fitted = x => {
    let Xvec = model(x)
    let out = 0.0
    for i in range(Xvec.len()) {
      out += Xvec.at(i) * beta.at(i).at(0)
    }
    return out
  }

  if domain == auto {
    let min = data.fold(data.at(0).at(0), (min, xy) => calc.min(min, xy.at(0)))
    let max = data.fold(data.at(0).at(0), (max, xy) => calc.max(max, xy.at(0)))
    domain = (min, max)
  }

  add(fitted, domain: domain, hypograph: hypograph, epigraph: epigraph,
      fill: fill, fill-type: fill-type, style: style, mark: mark,
      mark-size: mark-size, mark-style: mark-style, samples: samples,
      sample-at: sample-at, line: line, axes: axes, label: label)
}

