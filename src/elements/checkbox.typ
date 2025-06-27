#import "/src/elembic.typ" as e

/// A custom element representing a checkbox. By default, the `ballot` and `ballot.cross` symbols
/// are used, but that can be overridden by an elembic show rule:
///
/// #example(
///   mode: "markup",
///   ratio: 3,
///   scale-preview: 100%,
///   ```typ
///   >>>#import elements: checkbox
///   <<<#import scrutinize.elements: checkbox
///   *Default*: #lorem(2) #checkbox()#checkbox(checked: true) #lorem(3)
///   ```
/// )
///
/// #example(
///   mode: "markup",
///   ratio: 3,
///   scale-preview: 100%,
///   ```typ
///   >>>#import elembic as e
///   >>>#import elements: checkbox
///   <<<#import "@preview/elembic:1.1.0" as e
///   #show: e.show_(checkbox, it => {
///     let (checked,) = e.fields(it)
///     box(inset: (x: 1pt), circle(
///       radius: text.size / 3, stroke: 0.5pt,
///       fill: if checked { black },
///     ))
///   })
///   *Custom*: #lorem(2) #checkbox()#checkbox(checked: true) #lorem(3)
///   ```
/// )
///
/// *Fields:*
///
/// `checked` (#style.show-type("bool")) -- whether the checkbox is checked.
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
