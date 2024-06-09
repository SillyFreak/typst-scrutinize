alias all := compile-all
alias c := compile

compile-all: (compile "question-types") (compile "small-example") (compile-exam "gk-ek-austria") (compile-exam "test")

compile-exam exam:
	typst c "gallery/{{exam}}.typ" "gallery/{{exam}}.pdf"

compile-solution exam:
	typst c --input solution=true "gallery/{{exam}}.typ" "gallery/{{exam}}-solved.pdf"

compile exam: (compile-solution exam) (compile-exam exam)
