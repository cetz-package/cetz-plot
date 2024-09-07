#import "/src/plot/axis-styles/orthorect-2d/clipper.typ"

/// Compute clipped stroke paths
///
/// - points (array): X/Y data points
/// - low (vector): Lower clip-window coordinate
/// - high (vector): Upper clip-window coordinate
/// -> array List of stroke paths
#let compute-stroke-paths = clipper.clipped-paths-rect.with(fill: false, generate-edge-points: true)
/// Compute clipped fill path
///
/// - points (array): X/Y data points
/// - low (vector): Lower clip-window coordinate
/// - high (vector): Upper clip-window coordinate
/// -> array List of fill paths
#let compute-fill-paths = clipper.clipped-paths-rect.with(fill: true, generate-edge-points: true)
