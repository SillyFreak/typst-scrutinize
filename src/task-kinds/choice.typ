/// A checkbox which can be ticked by the student.
/// If the checkbox is a correct answer and the document is in solution mode, it will be ticked.
///
/// Example:
///
/// #task-example(
///   ```typ
///   #import task-kinds.choice: checkbox
///   Correct: #checkbox(true) -- Incorrect: #checkbox(false)
///   ```
/// )
/// - correct (boolean): whether the checkbox is of a correct answer
/// -> content
#let checkbox(correct) = context {
  import "../solution.typ"

  if (solution.get() and correct) { sym.ballot.x } else { sym.ballot }
}

/// A table with multiple options that can each be true or false.
/// Each option is a tuple consisting of content and a boolean for whether the option is correct or not.
///
/// Example:
///
/// #task-example(
///   ```typ
///   #import task-kinds: choice
///   #choice.multiple(
///     range(1, 6).map(i => ([Answer #i], calc.even(i))),
///   )
///   ```
/// )
///
/// - options (array): an array of (option, correct) pairs
/// -> content
#let multiple(options) = {
  table(
    columns: (auto, auto),
    align: (col, row) => (left, center).at(col) + horizon,

    ..for (option, correct) in options {
      (option, checkbox(correct))
    }
  )
}

/// A table with multiple options of which one can be true or false.
/// Each option is a content, and a second parameter specifies which option is correct.
///
/// Example:
///
/// #task-example(
///   ```typ
///   #import task-kinds: choice
///   #choice.single(
///     range(1, 6).map(i => [Answer #i]),
///     // 0-based indexing
///     3,
///   )
///   ```
/// )
///
/// - options (array): an array of contents
/// - answer (integer): the index of the correct answer, zero-based
/// -> content
#let single(options, answer) = {
  multiple(options.enumerate().map(((i, option)) => (option, i == answer)))
}
