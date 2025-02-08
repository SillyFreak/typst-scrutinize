#let _grid = grid

/// An answer filled in a gap in a text. If the document is not in solution mode, the answer is
/// hidden but the width of the element is preserved.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds.gap: gap
/// #set par(leading: 1em)
/// This is a #gap(stretch: 200%)[difficult] question \
/// and it has #gap(placeholder: [...], width: 1cm, stroke: "box")[two] lines.
/// ```)
///
/// -> content
#let gap(
  /// the answer to (maybe) display
  /// -> content
  answer,
  /// the placeholder to display instead of hiding the answer. For the layout of exam and solution
  /// to match, this needs to have the same width as the answer.
  /// -> auto | content
  placeholder: auto,
  /// the width of the region where an answer can be written
  /// -> auto | relative
  width: auto,
  /// the amount by which the width of the answer region should be stretched relative to the
  /// required width of the provided solution. Can only be set to a value other than 100% if
  /// `width == auto`.
  /// -> ratio
  stretch: 100%,
  /// the stroke with which to mark the answer area. The special values `"underline"` or `"box"` may
  /// be given to draw one or four border lines with a default stroke.
  /// -> none | string | stroke
  stroke: "underline",
) = context {
  import "../solution.typ"
  let (answer, width, stroke) = (answer, width, stroke)

  assert(
    width == auto or stretch == 100%,
    message: "a `stretch` value other than 100% is only allowed if `width == auto`.",
  )
  assert(
    type(stroke) != str or stroke in ("underline", "box"),
    message: "for string values, only \"underline\" or \"box\" are allowed",
  )

  answer = solution.answer(answer, placeholder: placeholder, place-args: arguments(center))

  if stroke == "underline" {
    stroke = (bottom: 0.5pt)
  } else if stroke == "box" {
    stroke = 0.5pt
  }

  let answer-box = box.with(
    stroke: stroke,
    outset: (y: 0.4em),
    inset: (x: 0.4em),
    align(center, answer),
  )

  if stretch != 100% {
    width = measure(answer-box()).width * stretch
  }
  answer-box(width: width)
}
