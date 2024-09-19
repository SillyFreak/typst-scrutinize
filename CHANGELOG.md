# [unreleased](https://github.com/SillyFreak/typst-scrutinize/releases/tag/)
## Added

## Removed

## Changed

## Migration Guide from v0.1.X

---

# [v0.2.0](https://github.com/SillyFreak/typst-scrutinize/releases/tag/v0.2.0)
Scrutinize 0.2.0 updates it to Typst 0.11.0, using context to simplify the API and --input to more easily specify if a sample solution is to be generated. Some documentation and metadata errors in the 0.1.0 submission were also corrected.

## Added
- specify solution state via `--input solution=true`

## Changed
- functions that formerly took callback parameters to give access to state now depend on context being provided and simply return a value

---

# [v0.1.0](https://github.com/SillyFreak/typst-scrutinize/releases/tag/v0.1.0)
Initial Release
