#import "/src/elembic.typ" as e

#let checkbox = e.element.declare(
  "checkbox",
  doc: "A checked or unchecked checkbox",
  prefix: "@preview/scrutinize,v1",

  display: it => {
    show: box.with(height: 0.65em)
    show: move.with(dy: -0.1em)
    set text(1.5em)
    if not it.checked {
        sym.ballot
    } else if sys.version < version(0, 12, 0) {
      sym.ballot.x
    } else {
      sym.ballot.cross
    }
  },

  fields: (
    e.field("checked", bool, doc: "Whether the textbox is checked."),
  )
)
