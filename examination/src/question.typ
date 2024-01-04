#let _builtin_counter = counter

/// The question counter
///
/// Example:
///
/// ```typ
/// #show heading.where(level: 2): it => [Question #question.counter.display()]
/// ```
///
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
/// The located question's metadata (a dictionary) is used to call the provided function.
///
/// If the optional `loc` is provided, that location is used and the function's result is returned directly;
/// otherwise, the result will be converted to a `content` by the necessary call to `locate`.
///
/// Example:
///
/// ```typ
/// #question.current(q => [This question is worth #q.points points.])
///
/// #locate(loc => {
///   let points = question.current(loc: loc, q => q.points)
///   // note that `points` is an integer, not a content!
///   let points-with-extra = points + 1
///   // but eventually, `locate()` will convert to content
///   [I may award up to #points-with-extra points for great answers!]
/// })
/// ```
///
/// - func (function): a function that receives a metadata dictionary
/// - loc (location): if given, this is used to find the current question instead of `locate()`
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

/// Locates all questions in the document, which can then be used to create grading keys etc.
/// The array of located `metadata` objects is used to call the provided function;
/// note that this is different from @@current(), where only the metadata dictionary is returned!
/// The reasoning is that the locations of different questions may be useful for further queries,
/// whereas for the current question having access to that location is not that useful.
/// Use `map(q => q.value)` to only access the dictionaries.
///
/// If the optional `loc` is provided, that location is used and the function's result is returned directly;
/// otherwise, the result will be converted to a `content` by the necessary call to `locate`.
///
/// Example:
///
/// ```typ
/// #question.all(qs => [There are #qs.len() questions.])
///
/// #locate(loc => {
///   let qs = question.all(loc: loc, qs => qs.map(q => q.value))
///   // note that `qs` is an array, not a content!
///   // but eventually, `locate()` will convert to content
///   [The first question is worth #qs.first().points points!]
/// })
/// ```
///
/// - func (function): a function that receives an array of `metadata` objects
/// - loc (location): if given, this is used to find the current question instead of `locate()`
/// -> content | any
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