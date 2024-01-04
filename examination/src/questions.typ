#let solution = state("examination-solution", false)

#let set-solution() = solution.update(true)

#let is-solution(func-or-loc) = {
  let inner(loc) = solution.at(loc)

  if type(func-or-loc) == function {
    let func = func-or-loc
    // find value, transform it into content
    locate(loc => func(inner(loc)))
  } else if type(func-or-loc) == location {
    let loc = func-or-loc
    // find value, return it
    inner(loc)
  } else {
    panic("function or location expected")
  }
}

#let free-text-answer(answer, height: auto) = is-solution(solution => {
  let answer = block(inset: (x: 2em, y: 1em), height: height, answer)
  if (not solution) {
    answer = hide(answer)
  }
  answer
})

#let checkbox(correct) = is-solution(solution => {
  if (solution and correct) { sym.ballot.x } else { sym.ballot }
})

#let multiple-choice(options) = {
  table(
    columns: (auto, auto),
    align: (col, row) => (left, center).at(col) + horizon,

    ..options.map(((option, correct)) => (
      option,
      checkbox(correct),
    )).flatten()
  )
}

#let single-choice(options, answer) = {
  multiple-choice(options.enumerate().map(((i, option)) => (option, i == answer)))
}
