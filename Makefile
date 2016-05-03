# A Makefile for compiling LaTeX documents.
#------------------------------------------------------------------------------
OBJECT		= thesis
BIBTEX		= true
LATEX		= pdflatex
SOURCES		= $(OBJECT).tex $(wildcard *.tex) $(wildcard ./*/*.tex)
CMP=$(shell cat stats/compiled)
.SUFFIXES: .tex .dvi .ps .pdf .ps.gz .bbl .dat

.tex.pdf:
	$(LATEX) -shell-escape $* --enable-write18
	$(LATEX) -shell-escape $* --enable-write18
	echo "$(CMP) + 1" | bc > stats/compiled
	pdfinfo thesis.pdf | grep "Pages" | awk '{printf $$2}' > stats/pages
	pdftotext thesis.pdf - | LC_ALL=C  tr " " "\n" | grep -E "^[A-Za-z]+$$" | wc -l > stats/words
	pdftotext thesis.pdf - | LC_ALL=C  grep -oE "Figure [0-9]+.[0-9]+" | sort | uniq | wc -l > stats/figures
	git rev-list HEAD --count > stats/commits
	git log -1 --pretty=%B > stats/lastmessage

.tex.bbl:
	$(LATEX) -shell-escape $* --enable-write18
	$(BSTINPUTS) bibtex $*

default: pdf
pdf: $(OBJECT).pdf

tidy:
	rm -f *.aux *.toc *.log *.out  *.bbl *.blg *.idx *.lot *.lof $(OBJECT)_dvi.* $(OBJECT)_pdf.* */*.aux
clean: tidy
	rm -f $(OBJECT).dvi $(OBJECT).pdf $(OBJECT)-figure*.pdf $(OBJECT)-figure*.dep $(OBJECT)-figure*.dpth $(OBJECT)-figure*.table $(OBJECT)-figure*.gnuplot $(OBJECT).ps

$(OBJECT).pdf: $(OBJECT).bbl $(OBJECT).tex $(SOURCES)
$(OBJECT).bbl: $(OBJECT).tex references.bib $(SOURCES)
