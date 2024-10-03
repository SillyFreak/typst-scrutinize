#let _grid = grid

/// An answer filled in a gap in a text. If the document is not in solution mode, the answer is
/// hidden but the height of the element is preserved.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds.gap: gap
/// #set par(leading: 1em)
/// This is a #gap(width: 2cm)[difficult] question \
/// and it has #gap(width: 1.2cm, stroke: "box")[two] lines.
/// ```)
///
/// - answer (content): the answer to (maybe) display
/// - width (auto, relative): the width of the region where an answer can be written
/// - stroke (none, string, stroke): the stroke with which to mark the answer area. The special
///   values `"underline"` or `"box"` may be given to draw one or four border lines with a default
///   stroke.
/// -> content
#let gap(answer, width: auto, stroke: "underline") = context {
  import "../solution.typ"

  let stroke = stroke
  assert(
    type(stroke) != str or stroke in ("underline", "box"),
    message: "for string values, only \"underline\" or \"box\" are allowed",
  )
  if stroke == "underline" {
    stroke = (bottom: 0.5pt)
  } else if stroke == "box" {
    stroke = 0.5pt
  }

  let answer = answer
  if (not solution.get()) {
    answer = hide(answer)
  }

  box(width: width, stroke: stroke, outset: (y: 0.4em), align(center, answer))
}
