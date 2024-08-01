/// Add an anchor to a plot environment
///
/// This function is similar to `draw.anchor` but it takes an additional
/// axis tuple to specify which axis coordinate system to use.
///
/// #example(```
/// import cetz.plot
/// import cetz.draw: *
/// plot.plot(size: (2,2), name: "plot",
///           x-tick-step: none, y-tick-step: none, {
///   plot.add(((0,0), (1,1), (2,.5), (4,3)))
///   plot.add-anchor("pt", (1,1))
/// })
///
/// line("plot.pt", ((), "|-", (0,1.5)), mark: (start: ">"), name: "line")
/// content("line.end", [Here], anchor: "south", padding: .1)
/// ```)
///
/// - name (string): Anchor name
/// - position (tuple): Tuple of x and y values.
///   Both values can have the special values "min" and
///   "max", which resolve to the axis min/max value.
///   Position is in axis space defined by the axes passed to `axes`.
/// - axes (tuple): Name of the axes to use `("x", "y")` as coordinate
///   system for `position`. Note that both axes must be used,
///   as `add-anchors` does not create them on demand.
#let anchor(name, position, axes: ("x", "y")) = {
  ((
    type: "anchor",
    name: name,
    position: position,
    axes: axes,
  ),)
}