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
/// #import "@preview/elembic:1.1.0" as e
///
/// // equivalent vanilla Typst show/set rules:
/// // #show choice.multiple.where(direction: ltr): set choice.multiple(boxes: left)
/// // #show choice.multiple.where(direction: ltr): set table(stroke: none, ...)
/// #show: e.set_(choice.multiple.with(direction: ltr), boxes: left)
/// #show: e.show_(choice.multiple.with(direction: ltr), it => {
///   set table(stroke: none, inset: (x, y) => (
///     right: if calc.even(x) { 0pt } else { 0.8em },
///     rest: 5pt,
///   ))
///   it
/// })
///
/// #choice.multiple(
///   range(1, 6).map(i => ([Answer #i], calc.even(i))),
/// )
/// #choice.multiple(
///   direction: ltr,
///   range(1, 6).map(i => ([#i], calc.even(i))),
/// )
/// ```)
///
/// *Fields:*
///
/// `options` (#style.show-type("array")) -- an array of (option, correct) pairs
///
/// `boxes` (#style.show-type("alignment")) -- `left` or `right`, specifying on which side of the option the checkbox should appear
///
/// `direction` (#style.show-type("direction")) -- `ttb` or `ltr`, specifying how options should be arranged
#let multiple = {
  import "/src/elembic.typ" as e

  e.element.declare(
    "multiple",
    doc: "A multiple choice question",
    prefix: "@preview/scrutinize,v1",

    display: it => {
      let col-multiplier = if it.direction == ltr { it.options.len() } else { 1 }

      table(
        columns: (auto, auto) * col-multiplier,
        align: (col, row) => ((left, center) * col-multiplier).at(col) + horizon,

        ..for (option, correct) in it.options {
          if it.boxes == left {
            (checkbox(correct), option)
          } else {
            (option, checkbox(correct))
          }
        }
      )
    },

    fields: (
      e.field("options", array, doc: "an array of (option, correct) pairs", required: true),
      e.field("boxes", alignment, doc: "`left` or `right`, specifying on which side of the option the checkbox should appear", default: right),
      e.field("direction", direction, doc: "`ttb` or `ltr`, specifying how options should be arranged", default: ttb),
    )
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
