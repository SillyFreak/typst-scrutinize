#let _builtin_counter = counter

/// The question counter
/// -> counter
#let counter = _builtin_counter(<examination-question>)

/// Adds a question with its metadata, and renders it.
/// The questions can later be accessed using the other functions in this module.
///
/// - body (content): the content to be displayed for this question
/// - category (string): an optional category to be added to the question's metadata
/// - points (integer): an optional point score to be added to the question's metadata
/// -> content
#let q(
  body,
  category: none,
  points: none,
) = {
  [#metadata((category: category, points: points, body: body)) <examination-question>]
  body
}

/// Locates the most recently defined question;
/// within a @@q() call, that is the question _currently_ being defined.
/// The located question's metadata is used to call the provided function.
///
/// If the optional `loc` is provided, that location is used and the function's result is returned directly;
/// otherwise, the result will be converted to a `content` by the necessary call to `locate`.
///
/// - func (function): a function
/// - loc (location): a
/// -> content | any
#let current(
  func,
  loc: none,
) = {
  let inner(loc) = {
    let q = query(selector(<examination-question>).before(loc), loc).last().value
    func(q)
  }

  if loc != none {
    inner(loc)
  } else {
    locate(inner)
  }
}

#let all(func, loc: none) = {
  let inner(loc) = {
    let qs = query(<examination-question>, loc)
    func(qs)
  }

  if loc != none {
    inner(loc)
  } else {
    locate(inner)
  }
}