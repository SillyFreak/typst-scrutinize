#import "../src/lib.typ": grading, question, questions
// #import "@local/examination:0.0.1": grading, question

// you usually want to alias this, as you'll need it often
#import question: q
#import questions: multiple-choice

// make the PDF reproducible to ease version control
#set document(date: none)

#set table(stroke: 0.5pt)

= Question

Which of these is the fourth answer?

#multiple-choice(
  (
    [Answer 1],
    [Answer 2],
    [Answer 3],
    [Answer 4],
    [Answer 5],
  ),
  3,
)
