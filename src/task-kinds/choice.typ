/// A checkbox which can be ticked by the student. If the checkbox is a correct answer and the
/// document is in solution mode, it will be ticked.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds.choice: checkbox
/// Correct: #checkbox(true) -- Incorrect: #checkbox(false)
/// ```)
///
/// -> content
#let checkbox(
  /// whether the checkbox is of a correct answer
  /// -> boolean
  correct,
) = context {
  import "../solution.typ"
  import "../elements/mod.typ": checkbox

  solution.answer(
    checkbox(correct),
    placeholder: checkbox(),
  )
}

/// A table with multiple options that can each be true or false. Each option is a tuple consisting
/// of content and a boolean for whether the option is correct or not.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds: choice
/// #choice.multiple(
///   range(1, 6).map(i => ([Answer #i], calc.even(i))),
/// )
/// #set table(stroke: none, inset: (x, y) => (
///   right: if calc.even(x) { 0pt } else { 0.8em },
///   rest: 5pt,
/// ))
/// #choice.multiple(
///   boxes: left,
///   direction: ltr,
///   range(1, 6).map(i => ([#i], calc.even(i))),
/// )
/// ```)
///
/// -> content
#let multiple(
  /// an array of (option, correct) pairs
  /// -> array
  options,
  /// `left` or `right`, specifying on which side of the option the checkbox should appear
  /// -> alignment
  boxes: right,
  /// `ttb` or `ltr`, specifying how options should be arranged
  /// -> direction
  direction: ttb,
  ) = {
  assert(boxes in (left, right))
  assert(direction in (ltr, ttb))

  let col-multiplier = if direction == ltr { options.len() } else { 1 }

  table(
    columns: (auto, auto) * col-multiplier,
    align: (col, row) => ((left, center) * col-multiplier).at(col) + horizon,

    ..for (option, correct) in options {
      if boxes == left {
        (checkbox(correct), option)
      } else {
        (option, checkbox(correct))
      }
    }
  )
}

/// A table with multiple options of which one can be true or false. Each option is a content, and a
/// second parameter specifies which option is correct.
///
/// Example:
///
/// #task-example(lines: "2-", ```typ
/// #import task-kinds: choice
/// #choice.single(
///   range(1, 6).map(i => [Answer #i]),
///   // 0-based indexing
///   3,
/// )
/// #set table(stroke: none, inset: (x, y) => (
///   right: if calc.even(x) { 0pt } else { 0.8em },
///   rest: 5pt,
/// ))
/// #choice.single(
///   boxes: left,
///   direction: ltr,
///   range(1, 6).map(i => [#i]),
///   3,
/// )
/// ```)
///
/// -> content
#let single(
  /// an array of contents
  /// -> array
  options,
  /// the index of the correct answer, zero-based
  /// -> integer
  answer,
  /// `left` or `right`, specifying on which side of the option the checkbox should appear
  /// -> alignment
  boxes: right,
  /// `ttb` or `ltr`, specifying how options should be arranged
  /// -> direction
  direction: ttb,
) = {
  multiple(
    boxes: boxes,
    direction: direction,
    options.enumerate().map(((i, option)) => (option, i == answer)),
  )
}
