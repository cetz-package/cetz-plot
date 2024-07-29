// Compare two floats
#let _compare(a, b, eps: 1e-6) = {
  return calc.abs(a - b) <= eps
}

// Pre-computed table of fractions
#let _common-denoms = range(2, 11 + 1).map(d => {
  (d, range(1, d).map(n => n/d))
})

#let _find-fraction(v, denom: auto, eps: 1e-6) = {
  let i = calc.floor(v)
  let f = v - i
  if _compare(f, 0, eps: eps) {
    return $#v$
  }

  let denom = if denom != auto {
    for n in range(1, denom) {
      if _compare(f, n/denom, eps: eps) {
        denom
      }
    }
  } else {
    (() => {
      for ((denom, tab)) in _common-denoms {
        for vv in tab {
          if _compare(f, vv, eps: eps) {
            return denom
          }
        }
      }
    })()
  }

  if denom != none {
    return if v < 0 { $-$ } else {} + $#calc.round(calc.abs(v) * denom)/#denom$
  }
}

/// Fraction tick formatter
///
/// - value (number): Value to format
/// - denom (auto, int): Denominator for result fractions. If set to `auto`,
///   a hardcoded fraction table is used for finding fractions with a
///   denominator <= 11.
/// - eps (number): Epsilon used for comparison
/// -> Content if a matching fraction could be found or none
#let fraction(value, denom: auto, eps: 1e-6) = {
  return _find-fraction(value, denom: denom, eps: eps)
}

/// Multiple of tick formatter
///
/// ```example
/// plot.plot(x-format: plot.formats.multiple-of,
///           x-tick-step: calc.pi/4, {
///   plot.add(calc.sin, domain: (-calc.pi, 1.5 * calc.pi))
/// })
/// ```
///
/// - value (number): Value to format
/// - factor (number): Factor value is expected to be a multiple of.
/// - symbol (content): Suffix symbol. For `value` = 0, the symbol is not
///   appended.
/// - fraction (none, true, int): If not none, try finding matching fractions
///   using the same mechanism as `fraction`. If set to an integer, that integer
///   is used as denominator. If set to `none` or `false`, or if no fraction
///   could be found, a real number with `digits` digits is used.
/// - digits (int): Number of digits to use for rounding
/// - eps (number): Epsilon used for comparison
/// -> Content if a matching fraction could be found or none
#let multiple-of(value, factor: calc.pi, symbol: $pi$, fraction: true, digits: 2, eps: 1e-6) = {
  if _compare(value, 0, eps: eps) {
    return $0$
  }

  let a = value / factor
  if _compare(a, 1, eps: eps) {
    return symbol
  } else if _compare(a, -1, eps: eps) {
    return $-$ + symbol
  }

  if fraction != none {
    let frac = _find-fraction(a, denom: if fraction == true { auto } else { fraction })
    if frac != none {
      return frac + symbol
    }
  }

  return $#calc.round(a, digits: digits)$ + symbol
}

/// Scientific notation tick formatter
///
/// - value (number): Value to format
/// - digits (int): Number of digits for rouding the factor
/// -> Content
#let sci(value, digits: 2) = {
  let exponent = if value != 0 {
    calc.floor(calc.log(calc.abs(value), base: 10))
  } else {
    0
  }

  let ee = calc.pow(10, calc.abs(exponent + 1))
  if exponent > 0 {
    value = value / ee * 10
  } else if exponent < 0 {
    value = value * ee * 10
  }

  value = calc.round(value, digits: digits)
  if exponent <= -1 or exponent >= 1 {
    return $#value times 10^#exponent$
  }
  return $#value$
}
