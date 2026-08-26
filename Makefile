# ============================================================================
# Makefile -- build the TikZ figures in this folder
# ============================================================================
#
# Each figure (<name>.tex) is a bare tikzpicture. This Makefile wraps it in a
# minimal `standalone` document on the fly (see PREAMBLE below) that loads the
# two local tikz libraries and the colors/macros in figure-macros.tex, so each
# figure builds to its own tightly cropped pdf.
#
# See example.tex for a human-readable example of the same setup, showing how
# to drop these figures into your own document. It is NOT built by make.
#
# All output pdfs are written to the pdf/ directory.
#
# BUILD  (one cropped pdf per figure, in pdf/)
#   make                     build every figure         (default; same as: make all)
#   make <name>              build one figure           e.g.  make poseidon
#   make <name> <name> ...   build several              e.g.  make poseidon rescue
#   make FIGS="a b c"        build a selection
#
# COMBINE  (one multi-page pdf, one figure per page)
#   make combined                        merge ALL figures  -> pdf/all-figures.pdf
#   make combined FIGS="a b"             merge a selection  -> pdf/all-figures.pdf
#   make combined FIGS="a b" OUT=x.pdf   merge a selection  -> pdf/x.pdf
#
# INSPECT / CLEAN
#   make list        print the available figure names
#   make help        print this usage summary
#   make clean       remove auxiliary files (build/ dir + stray *.aux, *.log, ...)
#   make distclean   clean, and also remove the generated pdfs
#
# NOTES
#   * `make poseidon rescue` and `make FIGS="poseidon rescue"` build the same
#     pdfs. Use FIGS="..." when the selection must also feed `combined` or
#     `distclean`; bare names cannot subset those (`make combined poseidon`
#     builds the full all-figures.pdf plus a separate poseidon.pdf).
#   * Builds are incremental: a figure recompiles only when its own .tex,
#     figure-macros.tex, a tikz library, or this Makefile changes.
#   * No .aux/.log clutter lands beside the sources -- each figure compiles
#     inside build/ and only the finished pdf is copied out. (A *direct* editor
#     compile of example.tex does drop aux here; `make clean` sweeps that too.)
#   * clean keeps the pdfs; distclean also removes the whole pdf/ directory
#     (and a stray example.pdf). OUT="..." is taken relative to pdf/, so a
#     custom combined name is removed by distclean too.
#   * Requires: pdflatex (build) and pdfunite (combine).
# ============================================================================

LATEX       := pdflatex
LATEXFLAGS  := -interaction=nonstopmode -halt-on-error
MACROS      := figure-macros.tex
LIBS        := tikzlibrarystap.components.code.tex
BUILDDIR    := build
PDFDIR      := pdf

# minimal standalone wrapper each figure is compiled in (kept in sync with the
# preamble shown in example.tex). \input{<name>} is appended per figure below.
PREAMBLE := \documentclass[border=5pt]{standalone}\usepackage{amsmath,amssymb}\usepackage{tikz}\usetikzlibrary{stap.components}\input{$(MACROS)}

# let pdflatex find the macros and local tikz libraries
export TEXINPUTS := .:$(CURDIR):$(TEXINPUTS)

# every *.tex that is a figure (exclude the example, macros, libs, and the paper)
FIGURES := $(filter-out example.tex $(MACROS) primitives2.tex $(wildcard tikzlibrary*.tex),$(wildcard *.tex))
NAMES   := $(FIGURES:.tex=)

# selection: defaults to all figures; override on the command line, e.g.
#   make FIGS="poseidon rescue"
FIGS ?= $(NAMES)
PDFS := $(addprefix $(PDFDIR)/,$(addsuffix .pdf,$(FIGS)))

# combined-pdf name, interpreted relative to $(PDFDIR)/ (override with OUT=...)
OUT ?= all-figures.pdf
OUTPATH := $(PDFDIR)/$(OUT)

# rebuild a figure if its source, the macros, a library, or the wrapper
# (which lives in this Makefile) changes
DEPS := $(MACROS) $(LIBS) $(firstword $(MAKEFILE_LIST))

.PHONY: all combined list help clean distclean $(NAMES)

all: $(PDFS)

# print the usage summary at the top of this file
help:
	@awk '/^# =/{next} /^#/{sub(/^# ?/,""); print; next} {exit}' $(firstword $(MAKEFILE_LIST))

# bare figure name is an alias for its pdf, so `make poseidon rescue` works
$(NAMES): %: $(PDFDIR)/%.pdf

# one figure -> $(PDFDIR)/<name>.pdf (aux files stay in build/)
$(PDFDIR)/%.pdf: %.tex $(DEPS)
	@mkdir -p $(BUILDDIR) $(PDFDIR)
	@echo "  LATEX   $*"
	@$(LATEX) $(LATEXFLAGS) -jobname=$* -output-directory=$(BUILDDIR) \
	    "$(PREAMBLE)\begin{document}\input{$*}\end{document}" > $(BUILDDIR)/$*.build.log 2>&1 \
	    || { echo "  FAILED  $* (see $(BUILDDIR)/$*.build.log)"; exit 1; }
	@cp $(BUILDDIR)/$*.pdf $@

combined: $(PDFS)
	@mkdir -p $(dir $(OUTPATH))
	@echo "  UNITE   $(OUTPATH) ($(words $(PDFS)) pages)"
	@pdfunite $(PDFS) $(OUTPATH)

list:
	@echo $(NAMES) | tr ' ' '\n'

# auxiliary extensions left behind by a *direct* compile (pdflatex figures.tex
# in an editor) -- the Makefile itself keeps these inside build/
AUXEXT := aux log out fls fdb_latexmk synctex.gz nav snm toc vrb

clean:
	@echo "  CLEAN   $(BUILDDIR)/ + aux files"
	@$(RM) -r $(BUILDDIR)
	@$(RM) $(foreach e,$(AUXEXT),*.$(e)) *.synctex\(busy\)

distclean: clean
	@echo "  CLEAN   $(PDFDIR)/ + example.pdf"
	@$(RM) -r $(PDFDIR)
	@$(RM) example.pdf
