///
#let total-points(questions, filter: none) = {
  if filter != none {
    questions = questions.filter(q => filter(q.value))
  }
  questions.map(q => q.value.points).sum()
}

///
#let grades(..args) = {
  assert(args.named().len() == 0)
  let args = args.pos()
  assert(calc.odd(args.len()))

  let result = ()

  for i in range(0, args.len(), step: 2) {
    result.push((
      body: args.at(i),
      lower-limit: if i > 0 { args.at(i - 1) },
      upper-limit: if i < args.len() - 1 { args.at(i + 1) },
    ))
  }

  result
}