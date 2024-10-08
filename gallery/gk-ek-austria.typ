// #import "@preview/scrutinize:0.2.0": grading, question, questions
#import "../src/lib.typ" as scrutinize: grading, task, solution, task-kinds
#import task: t

// make the PDF reproducible to ease version control
#set document(date: none)

#let title = "Praktische Leistungsfeststellung"

#set document(title: title)
#set text(lang: "de")

#let categories = (
  (id: "mt", body: [Anwendungsentwicklung -- Multithreading]),
  (id: "sock", body: [Anwendungsentwicklung -- Sockets]),
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
      [Datum: ],
    )
  },
)

#set table(stroke: 0.5pt)

#show heading.where(level: 2): set heading(
  supplement: [Frage],
  numbering: (..nums) => numbering("1", ..nums.pos().slice(1)),
)
#show heading.where(level: 2): it => {
  show: block
  let t = task.current(level: 2).data
  [#it.supplement #counter(heading).display()]
  if it.body != [] {
    [: #it.body]
  }
  if t.points != none {
    [#h(1fr) #none / #t.points P.]
  }
  if t.at("extended", default: false) {
    [ EK]
  }
}

#context {
  let ts = task.all(level: 2)
  set text(size: 10pt)

  let points(category, extended) = {
    grading.total-points(ts, filter: t => {
      t.data.category == category and t.data.at("extended", default: false) == extended
    })
  }
  let category-points(category) = grading.total-points(ts, filter: t => t.data.category == category)

  let categories = categories.map((category) => {
    let gk = points(category.id, false)
    let ek = points(category.id, true)
    (..category, gk: gk, ek: ek)
  })

  let total = grading.total-points(ts)

  let grades = grading.grades(
    [Nicht Genügend (5)],
    4/8 * total,
    [Genügend (4)],
    5/8 * total,
    [Befriedigend (3)],
    6/8 * total,
    [Gut (2)],
    7/8 * total,
    [Sehr Gut (1)],
  )

  let grades = grades.map(((body, lower-limit, upper-limit)) => {
    if lower-limit == none {
      (body: body, range: [< #upper-limit P.])
    } else if upper-limit != none {
      (body: body, range: [#(lower-limit + 0.5) - #upper-limit P.])
    } else {
      (body: body, range: [#(lower-limit + 0.5) - #total P.])
    }
  })

  [
    = Punkte nach Kompetenzbereichen

    #table(
      columns: (3fr, ..(1fr,) * 3),
      align: (col, row) =>
        if col == 0 { left + horizon }
        else { right + horizon },

      [*Kompetenzbereich*], [*Punkte GK*], [*Punkte EK*], [*Punkte Gesamt*],
      ..for (id, body, gk, ek) in categories {
        (body, [#none / #gk], [#none / #ek], [#none / #(gk + ek)])
      },
      [Gesamt], [], [], [#none / #total],
    )

    = Notenschlüssel

    #table(
      columns: (auto, ..(1fr,) * grades.len()),
      align: (col, row) =>
        if col == 0 { left + horizon }
        else { center + horizon },

      [Punkte:],
      ..grades.map(g => g.range),

      [Note:],
      ..grades.map(g => g.body),
    )
  ]
}

= Grundkompetenzen -- Theorieteil Multithreading

#lorem(50)

==
#t(category: "mt", points: 2)
#lorem(40)

==
#t(category: "mt", points: 2)
#lorem(40)

==
#t(category: "mt", points: 2)
#lorem(40)

==
#t(category: "mt", points: 3)
#lorem(40)

= Grundkompetenzen -- Theorieteil Sockets

#lorem(50)

==
#t(category: "sock", points: 6)
  #lorem(50)
]

==
#t(category: "sock", points: 2)
  #lorem(30)
]

= Grund- und erweiterte Kompetenzen -- Praktischer Teil Multithreading

#lorem(80)

==
#t(category: "mt", points: 4)
#lorem(40)

==
#t(category: "mt", points: 3)
#lorem(40)

==
#t(category: "mt", points: 4)
#lorem(40)

==
#t(category: "mt", points: 4)
#lorem(40)

==
#t(category: "mt", points: 5, extended: true)
#lorem(40)

==
#t(category: "mt", points: 3, extended: true)
#lorem(40)

= Grund- und erweiterte Kompetenzen -- Praktischer Teil Sockets

#lorem(80)

==
#t(category: "sock", points: 6)
#lorem(40)

==
#t(category: "sock", points: 4)
#lorem(40)

==
#t(category: "sock", points: 6)
#lorem(40)

==
#t(category: "sock", points: 3, extended: true)
#lorem(40)

==
#t(category: "sock", points: 5, extended: true)
#lorem(40)
