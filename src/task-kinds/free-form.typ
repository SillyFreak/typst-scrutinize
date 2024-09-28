#let _grid = grid

/// An answer to a free form question. If the document is not in solution mode, the answer is hidden
/// but the height of the element is preserved.
///
/// Example:
///
/// #task-example(lines: "2-7", ```typ
/// #import task-kinds: free-form
/// Write an answer.
/// #free-form.plain(pad(top: 1em, bottom: 1em)[
///   an answer
/// ])
/// Next question
/// ```)
///
/// - answer (content): the answer to (maybe) display
/// - height (auto, relative): the height of the region where an answer can be written
/// -> content
#let plain(answer, height: auto) = context {
  import "../solution.typ"

  let answer = answer
  if (not solution.get()) {
    answer = hide(answer)
  }

  block(height: height, answer)
}

/// An answer to a free form question. If the document is not in solution mode, the answer is hidden
/// but the height of the element is preserved.
///
/// This answer type is meant for text questions and shows a lines to write on. By default, the
/// lines are spaced to match a regular paragraph (assuming the text styles are not changed within
/// the answer) and the number of lines depends on what is needed for the sample solution. If a
/// `line-height` is explicitly set, the `par.leading` is adjusted to make the sample solution
/// fit the lines. Paragraph spacing is currently not adjusted, so for the answer to look nice, it
/// should only be a single paragraph.
///
/// Example:
///
/// #task-example(lines: "2-5", ```typ
/// #import task-kinds: free-form
/// Write an answer.
/// #free-form.lines(line-height: 1cm)[this answer takes \ more than one line]
/// Next question
/// ```)
///
/// - answer (content): the answer to (maybe) display
/// - count (auto, int): the number of lines to show; defaults to however many are needed for the
///   answer
/// - line-height (relative): the line height; defaults to what printed lines naturally take
/// -> content
#let lines(answer, count: auto, line-height: auto) = context {
  import "../solution.typ"

  // the height advance of one line
  let line-advance = measure[a\ a].height - measure[a].height

  // if line-height is manually set, increase the leading by the discrepancy
  set par(leading: par.leading + line-height - line-advance) if line-height != auto
  // if line-height is not set, use the advance
  let line-height = line-height
  if line-height == auto {
    line-height = line-advance
  }

  // layout starts a new context block so now we can measure using the new leading
  layout(((width,)) => {
    let lines = if count != auto {
      count
    } else {
      // measure the height, then divide by the line height; round up
      calc.ceil(measure(block(width: width, answer)).height / line-height)
    }

    let answer = answer
    if (not solution.get()) {
      answer = hide(answer)
    }

    block({
      v(-0.3em)
      _grid(
        columns: (1fr,),
        rows: (line-height,) * lines,
        stroke: (bottom: 0.5pt),
      )
      place(top, answer, dy: par.leading / 2)
    })
  })
}

/// An answer to a free form question. If the document is not in solution mode, the answer is hidden
/// but the height of the element is preserved.
///
/// This answer type is meant for math and graphing tasks and shows a grid of lines. By default, the
/// grid has a 5mm raster, and occupies enough vertical space to contain the answer. The grid fits
/// the available width; use padding or similar to make it more narrow.
///
/// #task-example(lines: "2-7", ```typ
/// #import task-kinds: free-form
/// Draw a circle.
/// #free-form.grid(height: 20mm, {
///   place(dx: 15mm, dy: 5mm, circle(radius: 5mm))
/// })
/// Next question
/// ```)
///
/// - answer (content): the answer to (maybe) display
/// - height (auto, relative): the height of the grid region
/// - size (relative, dictionary): grid size, or a dictionary containing `width` and `height`
/// -> content
#let grid(answer, height: auto, size: 5mm) = layout(((width,)) => {
  import "../solution.typ"

  let size = if type(size) == dictionary {
    size
  } else {
    (width: size, height: size)
  }

  let height = height
  if height == auto {
    height = measure(block(width: width, answer)).height
  }

  let columns = calc.floor(width / size.width)
  let rows = calc.ceil(height / size.height)

  let answer = answer
  if (not solution.get()) {
    answer = hide(answer)
  }

  block({
    _grid(
      columns: (size.width,) * columns,
      rows: (size.height,) * rows,
      stroke: 0.5pt+gray,
    )
    place(top, answer)
  })
})
