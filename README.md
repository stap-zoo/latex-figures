# ZK-friendly hash function figures

TikZ figures for arithmetization-oriented / ZK-friendly hash functions. Each `<name>.tex` is a bare
`tikzpicture` fragment meant to be `\input` into a document.

## Requirements

- `pdflatex` (with the `standalone` class and PGF/TikZ)
- `pdfunite` (from poppler) — only for `make combined`

## Build
 
**All generated pdfs go into the `pdf/` directory** (created automatically).

```sh
make                     # build every figure -> pdf/<name>.pdf (cropped)
make poseidon rescue     # build just these
make FIGS="poseidon rc"  # same, via a variable
make combined            # merge all figures -> pdf/all-figures.pdf (one per page)
make list                # list available figure names
make help                # full usage
make clean               # remove aux files (build/ + stray *.aux, *.log, ...)
make distclean           # clean + remove the pdf/ directory
```

So `make poseidon` writes `pdf/poseidon.pdf`, and `make combined` writes
`pdf/all-figures.pdf` (a custom `OUT=zoo.pdf` becomes `pdf/zoo.pdf`). Builds are
incremental and leave no `.aux`/`.log` clutter beside the sources: each figure is
compiled inside `build/`, and only the finished pdf is copied into `pdf/`.

## Use in your own document

Your preamble needs three things (see **`example.tex`** for a working demo):

```latex
\usepackage{tikz}
\usetikzlibrary{stap.components}  % tikzlibrarystap.components.code.tex
\input{figure-macros}            % colors + macros the figures expect
```

The `tikzlibrarystap.components.code.tex` file must be on TeX's search path (e.g.
in the same folder). Then place a figure wherever you want it:

```latex
\begin{figure}
  \centering
  \resizebox{\linewidth}{!}{\input{poseidon}}
  \caption{The Poseidon permutation.}
\end{figure}
```

## Files

| File | Purpose |
|------|---------|
| `<name>.tex` | the figures (bare `tikzpicture`s) |
| `figure-macros.tex` | colors (`typeone`–`typefour`) and macros (`\M`, `\openFlystel`, …) the figures rely on |
| `example.tex` | example document showing how to include the figures (ignored by `make`) |
| `Makefile` | build system |
| `tikzlibrarystap.components.code.tex` | the custom TikZ component library (S-boxes, layers, operators, wires, braces) |
| `pdf/` | generated output pdfs (created by `make`, removed by `make distclean`) |
| `build/` | scratch dir for `.aux`/`.log`/… during compilation (removed by `make clean`) |


