root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
	@just --list --unsorted

# generate manual
doc:
	typst compile docs/manual.typ docs/manual.pdf
	for f in $(find gallery -maxdepth 1 -name '*.typ'); do typst c "$f"; done
	for f in question-types small-example example; do typst c --input solution=true "gallery/$f.typ" "gallery/$f-solved.pdf"; done

	mkdir -p tmp
	typst c --ppi 250 "gallery/example.typ" "tmp/example{n}.png"
	typst c --ppi 250 "gallery/example.typ" "tmp/example-solved{n}.png" --input solution=true
	mv tmp/example1.png thumbnail.png
	mv tmp/example-solved1.png thumbnail-solved.png
	rm tmp/example*.png
	rmdir tmp

# run test suite
test *args:
	typst-test run {{ args }}

# update test cases
update *args:
	typst-test update {{ args }}

# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")

# run ci suite
ci: test doc
