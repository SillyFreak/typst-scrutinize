// #import "@preview/scrutinize:0.2.0": grading, question, questions
#import "../src/lib.typ" as scrutinize: grading, task, solution, task-kinds
#import task-kinds: free-form, gap, choice
#import task: t

// make the PDF reproducible to ease version control
#set document(date: none)

#let title = "Exam"

#set document(title: title)
#set text(lang: "de")

#let categories = (
  (id: "a", body: [Topic A]),
  (id: "b", body: [Topic B]),
)

#set page(
  paper: "a4",
  margin: (x: 1.5cm, y: 2cm, top: 4cm),
  header-ascent: 20%,
  // header: locate(loc => {
  //   if calc.odd(loc.page()) {
  //   }
  // }),
  header: {
    set text(size: 10pt)

    table(
      columns: (1fr,) * 3,
      stroke: none,
      align: (col, row) => (left, center, left).at(col) + horizon,

      [],
      [*#title*],
      [],

      [Name:],
      [],
      [Date: ],
    )
  },
)

#let t-data(t) = (points: none, category: none, extended: false, ..t.data)

#set table(stroke: 0.5pt)
#set table.hline(stroke: 0.5pt)
#set table.vline(stroke: 0.5pt)

#show heading.where(level: 2): set heading(
  supplement: [Task],
  numbering: (..nums) => numbering("1", ..nums.pos().slice(1)),
)
#show heading.where(level: 2): it => {
  let t = t-data(task.current(level: 2))

  show: block
  [#it.supplement #counter(heading).display()]
  if (it.body != []) [: #it.body]
  if t.points != none or t.extended { h(1fr) }
  if t.points != none [#solution.answer[#t.points] / #t.points P.]
  if t.extended [ (ext.)]
}

#context {
  set text(size: 9pt)
  set table(stroke: none)

  let ts = task.all(level: 2)

  let points(category, extended) = {
    grading.total-points(ts.filter(t => {
      let t = t-data(t)
      t.category == category and t.extended == extended
    }))
  }

  let categories = categories.map((category) => {
    let gk = points(category.id, false)
    let ek = points(category.id, true)
    (..category, gk: gk, ek: ek)
  })

  let total = grading.total-points(ts)

  let grades = grading.grades(
    [F],
    0.6 * total,
    [D],
    0.7 * total,
    [C],
    0.8 * total,
    [B],
    0.9 * total,
    [A],
  )

  let grades = grades.map(((body, lower-limit, upper-limit)) => {
    if lower-limit == none {
      (body: body, range: [< #(upper-limit - 0.5) P.])
    } else if upper-limit != none {
      (body: body, range: [#lower-limit - #(upper-limit - 0.5) P.])
    } else {
      (body: body, range: [#lower-limit - #total P.])
    }
  })

  let points(pts) = [#solution.answer[#pts] / #pts]

  table(
    columns: (2fr, ..(1fr,) * 3),
    align: (x, y) => horizon + {
      if y == 0 { center }
      else if x == 0 { left }
      else { right }
    },

    table.header(
      [*Topic*], [*Basic competency*], [*Extended competency*], [*Total*],
    ),
    table.hline(),
    ..for (id, body, gk, ek) in categories {
      (table.cell(align: left, body), points(gk), points(ek), points(gk + ek))
    },
    table.hline(),
    [], [], [], points[#total],
  )

  [= Grading key]

  table(
    columns: (auto, ..(1fr,) * grades.len()),
    align: (col, row) => horizon + {
      if col == 0 { left }
      else { center }
    },

    [Points:],
    ..grades.map(g => g.range),

    [Grade:],
    ..grades.map(g => g.body),
  )
}

= Basic competencies -- theoretical part A

#lorem(40)

== Java Code
#t(category: "a", points: 3)
#lorem(30)

#{
  set text(1.4em)
  let gaps = (
    GAP1: "void",
    GAP2: "String[]",
  )

  show regex(gaps.keys().join("|")): placeholder => {
    let answer = gaps.at(placeholder.text)
    gap.gap(raw(lang: "java", answer), stretch: 200%)
  }

  ```java
  public static GAP1 main(GAP2 args) {
      // ...
  }
  ```
}

= Basic competencies -- theoretical part B

#lorem(40)

== Writing
#t(category: "b", points: 4)
#lorem(30)

#free-form.lines(stretch: 180%, lorem(20))

== Multiple Choice
#t(category: "b", points: 2)
#lorem(30)

#{
  set align(center)
  choice.multiple((
    (lorem(3), true),
    (lorem(5), true),
    (lorem(4), false),
  ))
}

= Basic and extended competencies -- practical part A

#lorem(80)

==
#t(category: "a", points: 4)
#lorem(30)

#free-form.grid(stretch: 200%, lorem(20))

==
#t(category: "a", points: 5)
#lorem(30)

#free-form.grid(stretch: 200%, lorem(20))

==
#t(category: "a", points: 4)
#lorem(30)

#free-form.grid(stretch: 200%, lorem(20))

== Complete a diagram, separate points category
#t(category: "a", points: 4, extended: true)
#lorem(40)

#{
  import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge

  set align(center)

  let automaton(solved) = {
    show: pad.with(y: 1em)
    diagram(
      node-stroke: .5pt,
      spacing: 3em,
      {
        let start = (-1, 0)
        let a = (0, 0)
        let b = (1, 0)
        let c = (2, 0)
        node(a, [a], radius: 1em)
        node(b, [b], radius: 1em)
        node(c, [c], radius: 1em, ..if solved { (extrude: (-4, 0)) })
        edge(start, a, "-|>", label-pos: 0, label-side: center)

        let stroke = if not solved { (stroke: white) }

        edge(a, b, "-|>", ..stroke)
        edge(b, c, "-|>", ..stroke)
        edge(a, a, "--|>", ..stroke, bend: 130deg)
        edge(a, c, "-|>", ..stroke, bend: -40deg)
      }
    )
  }

  free-form.plain(
    automaton(true),
    placeholder: automaton(false),
  )
}

#pagebreak(weak: true)

= Basic and extended competencies -- practical part B

#lorem(80)

==
#t(category: "b", points: 6)
#lorem(40)

#free-form.grid(stretch: 200%, lorem(20))

==
#t(category: "b", points: 4)
#lorem(40)

#free-form.grid(stretch: 200%, lorem(20))

==
#t(category: "b", points: 2, extended: true)
#lorem(40)

#free-form.grid(stretch: 300%, lorem(20))

==
#t(category: "b", points: 2, extended: true)
#lorem(40)

#free-form.grid(stretch: 200%, lorem(20))
