/// An answer to a free text question. If the document is not in solution mode,
/// the answer is hidden but the height of the element is preserved.
///
/// Example:
///
/// #task-example(
///   ```typ
///   #import task-kinds: free-form
///   Write an answer.
///   #free-form.plain[An answer]
///   Next question
///   ```
/// )
///
/// - answer (content): the answer to (maybe) display
/// - height (auto, relative): the height of the region where an answer can be written
/// -> content
#let plain(answer, height: auto) = context {
  import "../solution.typ"

  let answer = block(inset: (x: 2em, y: 1em), height: height, answer)
  if (not solution.get()) {
    answer = hide(answer)
  }
  answer
}
