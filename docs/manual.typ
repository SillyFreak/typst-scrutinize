#import "template.typ" as template: *
#import "/src/lib.typ": grading, task, solution, task-kinds

#import "@preview/crudo:0.1.1"

#let package-meta = toml("/typst.toml").package
#let date = datetime(year: 2024, month: 10, day: 12)

#show: manual(
  title: "Scrutinize",
  // subtitle: "...",
  authors: package-meta.authors.map(a => a.split("<").at(0).trim()),
  abstract: [
    _Scrutinize_ is a library for building exams, tests, etc. with Typst.
    It provides utilities for common task types and supports creating grading keys and sample solutions.
  ],
  url: package-meta.repository,
  version: package-meta.version,
  date: date,
)

// the scope for evaluating expressions and documentation
#let scope = (grading: grading, task: task, solution: solution, task-kinds: task-kinds)

#let example(code, lines: none, cheat: none) = {
  // eval can't access the filesystem, so no imports.
  // for displaying, we add the imports; for running, we have the imported entries in `scope`
  let code-to-display = crudo.join(
    main: -1,
    crudo.map(
      ```typ
      #import "@preview/NAME:VERSION": grading, task, solution, task-kinds
      ```,
      line => line.replace("NAME", package-meta.name).replace("VERSION", package-meta.version),
    ),
    code,
  )
  if lines != none {
    code-to-display = crudo.lines(code-to-display, lines)
  }

  let code-to-run = if cheat == none {
    code.text
  } else {
    // for when just executing the code as-is doesn't work in the docs
    cheat.text
  }

  set heading(numbering: none, outlined: false)
  show: task.scope

  [
    #code-to-display

    #preview-block(eval(code-to-run, mode: "markup", scope: scope))
  ]
}

#let task-example(task, lines: none) = {
  let cheat = crudo.join(
    main: 1,
    ```typ
    #let q = [
    ```,
    task,
    ```typ
    ]

    #grid(
      columns: (1fr, 1fr),
      column-gutter: 1em,
      solution.with(false, q),
      solution.with(true, q),
    )
    ```,
  )

  example(task, lines: lines, cheat: cheat)
}

#(scope.task-example = task-example)

= Introduction

_Scrutinize_ has three general areas of focus:

- It helps with grading information: record the points that can be reached for each task and make them available for creating grading keys.
- It provides a selection of task authoring tools, such as multiple choice or true/false questions.
- It supports the creation of sample solutions by allowing to switch between the normal and "pre-filled" exam.

Right now, providing a styled template is not part of this package's scope.

= Tasks and task metadata

Let's start with a really basic example that doesn't really show any of the benefits of this library yet:

#example(```typ
// you usually want to alias this, as you'll need it often
#import task: t

= Task
#t(points: 2)
#lorem(20)
```)

After importing the library's modules and aliasing an important function, we simply get the same output as if we didn't do anything. The one peculiar thing here is ```typc t(points: 2)```: this adds some metadata to the task. Any metadata can be specified, but `points` is special insofar as it is used by the `grading` module by default.

A lot of scrutinize's features revolve around using that metadata, and we'll soon see how. A task's metadata is a dictionary with the following fields:

- `data`: the explicitly given metadata of the task, such as ```typc (points: 2)```.
- `heading`: the heading that identifies the task, such as ```typ = Task```.
- `subtasks`: an array of nested tasks, identified by nested headings. When getting task metadata, you can limit the depth; this is only present as long as the depth is not exceeded.

Let's now look at how to retrieve metadata. Let's say we want to show the points in each task's header:

#example(lines: "5-8", ```typ
// you usually want to alias this, as you'll need it often
#import task: t

#show heading: it => {
  // here, we need to access the current task's metadata
  block[#it.body #h(1fr) / #task.current().data.points P.]
}

= Task
#t(points: 2)
#lorem(20)
```)

Here we're using the #ref-fn("task.current()") function to access the metadata of the current task. This function requires #link("https://typst.app/docs/reference/context/")[context] to know where in the document it is called, which a show rule already provides. The function documentation contains more details on how task metadata can be retrieved.

== Subtasks

Often, exams have not just multiple tasks, but those tasks are made up of several subtasks. Scrutinize supports this, and reuses Typst's heading hierarchy for subtask hierarchy.

Let's say some task's points come from its subtasks' points. This could be achieved like this:

#example(lines: "5-", ```typ
// you usually want to alias this, as you'll need it often
#import task: t

#show heading.where(level: 1): it => {
  let t = task.current(level: 1, depth: 2)
  block[#it.body #h(1fr) / #grading.total-points(t.subtasks) P.]
}
#show heading.where(level: 2): it => {
  let t = task.current(level: 2)
  block[#it.body #h(1fr) / #t.data.points P.]
}

= Task
#lorem(20)

== Subtask A
#t(points: 2)
#lorem(20)

== Subtask B
#t(points: 1)
#lorem(20)
```)

In this example, #ref-fn("task.current()") is used in conjunction with #ref-fn("grading.total-points()"), which recursively adds all points of a list of tasks and its subtasks. More about this function will be said in the next section, and of course in the function's reference.

#pagebreak(weak: true)

= Grading

The next puzzle piece is grading. There are many different possibilities to grade an exam; Scrutinize tries not to be tied to specific grading strategies, but it does assume that each task gets assigned points and that the grade results from looking at some kinds of sums of these points. If your test does not fit that schema, you can simply ignore the related features.

The first step in creating a typical grading scheme is determining how many points can be achieved in total, using #ref-fn("grading.total-points()"). We also need to use #ref-fn("task.all()") (with the `flatten` parameter) to get access to the task metadata distributed throughout the document:

#example(lines: "12-", ```typ
// you usually want to alias this, as you'll need it often
#import task: t

// let's show the available points to the right of each
// task's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current task's metadata
  block[#it.body #h(1fr) / #task.current().data.points]
}

#context [
  #let ts = task.all(flatten: true)
  #let total = grading.total-points(ts)
  #let hard = grading.total-points(ts.filter(t => t.data.points >= 5))
  Total points: #total \ Points from hard tasks: #hard
]

= Hard Task
#t(points: 6)
#lorem(20)

= Task
#t(points: 2)
#lorem(20)
```)

Once we have the total points of the exam figured out, we need to define the grading key. Let's say the grades are in a three-grade system of "bad", "okay", and "good". We could define these grades like this:

#example(lines: "12-19", ```typ
// you usually want to alias this, as you'll need it often
#import task: t

// let's show the available points to the right of each
// task's title and give the grader a space to put points
#show heading: it => {
  // here, we need to access the current task's metadata
  block[#it.body #h(1fr) / #task.current().data.points]
}

#context [
  #let total = grading.total-points(task.all(flatten: true))
  #grading.grades(
    [bad],
    total * 2/4, [okay],
    total * 3/4, [good],
  )
]

= Hard Task
#t(points: 6)
#lorem(20)

= Task
#t(points: 2)
#lorem(20)
```)

Obviously we would not want to render this representation as-is, but #ref-fn("grading.grades()") gives us a convenient way to have all the necessary information, without assuming things like inclusive or exclusive point ranges. The example in the gallery has a more complete demonstration of a grading key.

One thing to note is that #ref-fn("grading.grades()") does not process the limits of the grade ranges; they're simply passed through. If you prefer to ignore total points and instead show percentages, or want to use both, that is also possible:

#example(lines: "3-", ```typ
#let total = 8
#grading.grades(
  [bad],
  (points: total * 2/4, percent: 50%), [okay],
  (points: total * 3/4, percent: 75%), [good],
)
```)

#pagebreak(weak: true)

= Task templates and sample solutions

With the test structure out of the way, the next step is to actually define tasks. There are endless ways of posing tasks, but some recurring formats come up regularly.

#pad(x: 5%)[
  _Note:_ customizing the styles is currently very limited/not possible. I would be interested in changing this, so if you have ideas on how to achieve this, contact me and/or open a pull request. Until then, feel free to "customize using copy/paste". The MIT license allows you to do this.
]

Tasks have a desired response, and producing sample solutions can be made very convenient if they are stored with the task right away. To facilitate this, this package provides

- #ref-fn("solution._state"): this boolean state controls whether solutions are currently shown in the document. Some methods have convenience functions on the module level to make accessing them easier: #ref-fn("solution.get()"), #ref-fn("solution.update()").
- #ref-fn("solution.answer()"): this function uses the solution state to conditionally hide the provided answer.
- #ref-fn("solution.with()"): this function sets the solution state temporarily, before switching back to the original state.
  // The `small-example.typ` example in the gallery uses this to show a solved example task at the beginning of the document.

Additionally, the solution state can be set using the Typst CLI using `--input solution=true` (or `false`, which is already the default). Within context expressions, a task can use ```typ #solution.get()``` or ```typ #solution.answer()``` to find out whether solutions are shown. This is also used by Scrutinize's task templates.

Let's look at a free form question as a simple example:

== Free form questions

In free form questions, the student simply has some free space in which to put their answer:

#task-example(```typ
#import task-kinds: free-form

// toggle the following comment or pass `--input solution=true`
// to produce a sample solution
// #solution.update(true)

Write an answer.
#free-form.plain[An answer]
Next question
```)

Left is the unanswered version, right the answered one. Note that the answer occupies the same space regardless of whether it is displayed or not, and that the height can also be overridden - see #ref-fn("free-form.plain()").

The content of the answer is of course not limited to text; for example, the task could be to complete a diagram. The `placeholder` parameter is particularly useful for that, and the `stretch` parameter can be used to give students more space to write their solution than a printed version would take:

#task-example(lines: "8-", ```typ
#import task-kinds: free-form

// toggle the following comment or pass `--input solution=true`
// to produce a sample solution
// #solution.update(true)

Connect the nodes.
#free-form.plain(stretch: 200%, {
  stack(dir: ltr, spacing: 1cm, circle(radius: 3mm), circle(radius: 3mm))
  place(horizon, dx: 6mm, line(length: 1cm))
}, placeholder: {
  stack(dir: ltr, spacing: 1cm, circle(radius: 3mm), circle(radius: 3mm))
})
Next question
```)

There are also variations of the free-form question that use pre-printed lines or grids:

#task-example(lines: "8-", ```typ
#import task-kinds: free-form

// toggle the following comment or pass `--input solution=true`
// to produce a sample solution
// #solution.update(true)

Do something here.
#grid(
  columns: (1fr, 1fr),
  column-gutter: 0.5em,
  // 180% line height, 200% line count
  free-form.lines(stretch: 180%, count: 200%, lorem(5)),
  // solution needs four grid lines, six are printed
  free-form.grid(stretch: 133%, pad(5mm, line(end: (10mm, 10mm)))),
)
Next question
```)

== fill-in-the-gap questions

Related to free form questions are questions where the answer goes into a gap in the text. See #ref-fn("gap.gap()") for details.

#task-example(```typ
#import task-kinds.gap: gap

This question is #gap(stretch: 180%)[easy].

$ sin(0) = #gap(stroke: "box")[$0$] $
```)

== single and multiple choice questions

These taks types allow making a mark next to one or multiple choices. See #ref-fn("choice.single()") and #ref-fn("choice.multiple()") for details.

#task-example(```typ
#import task-kinds: choice

Which of these is the fourth answer?
#choice.single(
  range(1, 6).map(i => [Answer #i]),
  // 0-based indexing
  3,
)

Which of these answers are even?
#choice.multiple(
  range(1, 6).map(i => ([Answer #i], calc.even(i))),
)
```)

#pagebreak(weak: true)

= Module reference

// #module(
//   "scrutinize",
//   read("/src/lib.typ"),
//   label-prefix: none,
//   scope: scope,
// )

#module(
  read("/src/task.typ"),
  name: "scrutinize.task",
  label-prefix: "task",
  scope: scope,
)

#module(
  read("/src/grading.typ"),
  name: "scrutinize.grading",
  label-prefix: "grading",
  scope: scope,
)

#module(
  read("/src/solution.typ"),
  name: "scrutinize.solution",
  label-prefix: "solution",
  scope: scope,
)

#module(
  read("/src/task-kinds/choice.typ"),
  name: "scrutinize.task-kinds.choice",
  label-prefix: "choice",
  scope: scope,
)

#module(
  read("/src/task-kinds/free-form.typ"),
  name: "scrutinize.task-kinds.free-form",
  label-prefix: "free-form",
  scope: scope,
)

#module(
  read("/src/task-kinds/gap.typ"),
  name: "scrutinize.task-kinds.gap",
  label-prefix: "gap",
  scope: scope,
)
