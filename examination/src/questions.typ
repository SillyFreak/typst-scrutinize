#let multiple-choice(options, answer, solved: false) = {
  table(
    columns: (auto, auto),
    align: (col, row) => (left, center).at(col) + horizon,

    ..options.enumerate().map(((i, option)) => (
      option,
      if (solved and i == answer) { sym.ballot.x } else { sym.ballot },
    )).flatten()
  )
}
