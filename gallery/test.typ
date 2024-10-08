// #import "@preview/scrutinize:0.2.0": grading, question, questions
#import "../src/lib.typ" as scrutinize: grading, task, solution, task-kinds

// you usually want to alias this, as you'll need it often
#import task: t

// make the PDF reproducible to ease version control
#set document(date: none)

#set table(stroke: 0.5pt)

// let's show the available points to the right of each
// question's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current question's metadata
  block[#it.body #h(1fr) / #task.current().data.points]
}

// for grading, we need to consider all questions
#context {
  let ts = task.all()
  let total = grading.total-points(ts)
  // the total-points function can also accept a filter function
  let hard = grading.total-points(ts, filter: t => t.data.points >= 5)

  // create a grading key
  let grades = grading.grades([bad], total * 2/4, [okay], total * 3/4, [good])

  // adjust the key to you individual needs. Here
  // - for the lowest grade, the upper limit is exclusive, we render as "< limit"
  // - for the second lowest grade, both limits are inclusive, we render as "limit - limit"
  // - for the other grades, lower limit is exclusive, upper inclusive, we render as "limit - limit"
  //   for exclusivity, we add half a point to the limit and for the highest grade we use total points
  let grades = grades.enumerate().map(((i, (body, lower-limit, upper-limit))) => {
    if lower-limit == none {
      (body: body, range: [< #upper-limit P.])
    } else if i == 1 {
      (body: body, range: [#(lower-limit) - #upper-limit P.])
    } else if upper-limit != none {
      (body: body, range: [#(lower-limit + 0.5) - #upper-limit P.])
    } else {
      (body: body, range: [#(lower-limit + 0.5) - #total P.])
    }
  })

  // render a table with the points
  table(
    columns: (auto, ..(1fr,) * grades.len()),
    align: (col, row) =>
      if col == 0 { left + horizon }
      else { center + horizon },

    [Points],
    ..grades.map(g => g.range),

    [Grade],
    ..grades.map(g => g.body),
  )

  [Points from hard questions: #hard]
}

// the q function adds metadata to a question
= Hard Question
#t(points: 6)
#lorem(20)

#v(1fr)

#context [
  #let points = task.current().data.points

  This question is worth #points points.

  I may award up to #(points + 1) points for great answers!
]

= Question
#t(points: 2)
#lorem(20)

#v(1fr)
