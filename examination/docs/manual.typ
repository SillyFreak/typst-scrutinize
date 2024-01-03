#import "@preview/tidy:0.2.0"

#import "template.typ": *

// make the PDF reproducible to ease version control
#set document(date: none)

#let package-meta = toml("../typst.toml").package

#show: project.with(
  title: "Examination",
  // subtitle: "...",
  authors: package-meta.authors.map(a => a.split("<").at(0).trim()),
  abstract: [
    _Examination_ is a library for building exams, tests, etc. with Typst.
    It provides utilities for common question types and supports creating grading keys and sample solutions.
  ],
  // date: "December 22, 2023",
  version: package-meta.version,
  url: package-meta.repository
)

#pad(x: 10%, outline(depth: 1))
#pagebreak()

#let example(markup, lines: none, cheat: none) = [
  #if lines == none {
    markup
  } else {
    let (text, ..fields) = markup.fields()
    text = text.split("\n")
    text = text.slice(lines.at(0) - 1, lines.at(1))
    text = text.join("\n")

    raw(text, ..fields)
  }

  #let source = if cheat == none {
    markup.text
  } else {
    // for when just executing the code as-is doesn't work in the docs
    cheat.text
  }

  #tidy-output-figure(eval(source, mode: "markup"))
]

#let ref-fn(name) = link(label(name), raw(name))

= Introduction

_Examination_ has three general areas of focus:

- It provides a selection of question writing utilities, such as multiple choice or true/false questions.
- It helps with grading information: record the points that can be reached for each question and make them available for creating grading keys.
- It supports the creation of sample solutions by allowing to switch between the normal and "pre-filled" exam.

Right now, providing a styled template is not part of this package's scope.

= Questions and question metadata

Let's start with a really basic example that doesn't really show any of the benefits of this library yet:

#example(```typ
#import "../src/lib.typ": grading, question

// you usually want to alias this, as you'll need it often
#let q = question.q

#q(points: 2)[
  == Question

  #lorem(20)
]
```)

After importing the library's modules and aliasing an important function, we simply get the same output as if we didn't do anything. The one peculiar thing here is ```typc points: 2```: this adds some metadata to the question. Right now, the following metadata fields are available:

- `category`: an arbitrary category identifier (string) that can be used to group questions during further processing
- `points`: a number specifying how many points can be reached in that question
- additionally `body`: the complete content that was rendered as the question

The two former fields are not used unless you explicitly do so; let's look at how to do that. Let's say we want to show the points in each question's header:

#pagebreak(weak: true)

#example(lines: (6, 9), ```typ
#import "../src/lib.typ": grading, question

// you usually want to alias this, as you'll need it often
#let q = question.q

#show heading: it => {
  // here, we need to access the current question's metadata
  question.current(q => [#it.body #h(1fr) / #q.points])
}

#q(points: 2)[
  == Question

  #lorem(20)
]
```)

Here we're using the #ref-fn("question.current()") function to access the metadata of the current question. Like Typst's `locate()` function, ordinarily, any computation has to happen inside as it can only return content -- however, see the function's documentation for an escape hatch.

= Grading

The final puzzle piece is grading. There are many different possibilities to grade a test; right now Examination does not try to depend on a specific convention, but it does assume that in the end, a test has a final score and that the grade is derived by looking how high that score is. If your test does not fit that schema, you can simply use less of the related features.

The first step in creating a grading scheme is determining how many points can be achieved in total, using #ref-fn("grading.total-points()"). Let's at the same time also look at question categories as a way to get subtotals:

#example(lines: (13, 26), ```typ
#import "../src/lib.typ": grading, question

// you usually want to alias this, as you'll need it often
#let q = question.q

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  question.current(q => [#it.body #h(1fr) / #q.points])
}

#question.all(qs => [
  #let total = grading.total-points(qs)

  Total points: #total

  Points from hard questions:
  #grading.total-points(qs, filter: q => q.category == "hard")
])

#q(category: "hard", points: 6)[
  == Hard Question

  #lorem(20)
]

#q(points: 2)[
  == Question

  #lorem(20)
]
```, cheat: ```typ
#import "../src/lib.typ": grading, question

// you usually want to alias this, as you'll need it often
#let q = question.q

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  question.current(q => [#it.body #h(1fr) / #q.points])
}

#question.all(qs => [
  #let total = 8

  Total points: #total

  Points from hard questions:
  #grading.total-points(qs, filter: q => q.category == "hard")
])

#q(category: "hard", points: 6)[
  == Hard Question

  #lorem(20)
]

#q(points: 2)[
  == Question

  #lorem(20)
]
```)

Once we have the total points of the text figured out, we need to define the grading key. Let's say the grades are in a three-grade system of "bad", "okay", and "good". We could define these grades like this:

#example(lines: (13, 19), ```typ
#import "../src/lib.typ": grading, question

// you usually want to alias this, as you'll need it often
#let q = question.q

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  question.current(q => [#it.body #h(1fr) / #q.points])
}

#question.all(qs => [
  #let total = grading.total-points(qs)

  #let grades = grading.grades([bad], total * 2/4, [okay], total * 3/4, [good])

  #grades
])

#q(category: "hard", points: 6)[
  == Hard Question

  #lorem(20)
]

#q(points: 2)[
  == Question

  #lorem(20)
]
```, cheat: ```typ
#import "../src/lib.typ": grading, question

// you usually want to alias this, as you'll need it often
#let q = question.q

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  question.current(q => [#it.body #h(1fr) / #q.points])
}

#question.all(qs => [
  #let total = 8

  #let grades = grading.grades([bad], total * 2/4, [okay], total * 3/4, [good])

  #grades
])

#q(category: "hard", points: 6)[
  == Hard Question

  #lorem(20)
]

#q(points: 2)[
  == Question

  #lorem(20)
]
```)

Obviously we would not want to render this representation as-is, but #ref-fn("grading.grades()") gives us a convenient way to have all the necessary information, without assuming things like inclusive or exclusive point ranges. The `test.typ` example in the gallery has a more complete demonstration of a grading key.

= Question templates

TODO

= Sample solutions

TODO

= Module reference

#import "../src/lib.typ": grading, question

// == `examination`

// #{
//   let module = tidy.parse-module(
//     read("src/lib.typ"),
//     scope: (grading: grading, question: question),
//   )
//   tidy.show-module(
//     module,
//     sort-functions: none,
//     style: tidy.styles.minimal,
//   )
// }

== `examination.question`

#{
  let module = tidy.parse-module(
    read("../src/question.typ"),
    label-prefix: "question.",
    scope: (grading: grading, question: question),
  )
  tidy.show-module(
    module,
    sort-functions: none,
    style: tidy.styles.minimal,
  )
}

== `examination.grading`

#{
  let module = tidy.parse-module(
    read("../src/grading.typ"),
    label-prefix: "grading.",
    scope: (grading: grading, question: question),
  )
  tidy.show-module(
    module,
    sort-functions: none,
    style: tidy.styles.minimal,
  )
}
