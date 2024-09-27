// #import "@preview/scrutinize:0.2.0": grading, question, questions
#import "../src/lib.typ" as scrutinize: grading, task, solution, task-kinds
#import task: t
#import task-kinds: choice, free-form

// make the PDF reproducible to ease version control
#set document(date: none)

// toggle this comment or pass `--input solution=true` to produce a sample solution
// #questions.solution.update(true)

#set table(stroke: 0.5pt)

#context {
  // There is a level 1 heading before the actual exam questions; ignore that
  let ts = task.all(from: <begin-exam>)
  let total = grading.total-points(ts)

  [The candidate achieved #h(3em) out of #total points.]
}

= Instructions

#solution.with(true)[
  Use a pen. For multiple choice questions, make a cross in the box, such as in this example:

  #pad(x: 5%)[
    Which of these numbers are prime?

    #choice.multiple(
      (([1], false), ([2], true), ([3], true), ([4], false), ([5], true)),
    )
  ]
]

#metadata(none) <begin-exam>

#show heading: it => [
  #it.body #h(1fr) / #task.current().data.points
]

= Question 1
#t(points: 2)

Write an answer.

#free-form.lines(line-height: 12mm, count: 3)[
  An answer
]

= Question 2
#t(points: 1)

Select the largest number:


#choice.single(
  ([5], [20], [25], [10], [15]),
  2, // 0-based index
)
