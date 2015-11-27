# A Makefile for compiling LaTeX documents.  Written with thesis compilation in
# mind.  Lines to change include:
# * OBJECT: Change this to the name of the main thesis file without extension.
# * BIBTEX: Set this to true if you are using BibTeX for your citations; set it
#           to false otherwise.
# * LATEX: Set this to latex or pdflatex depending on what output format you
#          want and what figure formats are included in your thesis.
# * SOURCES: These are the individual tex files making up the thesis.
#
# Usage:
# make - Compile the thesis.  Output depends on the LATEX and BIBTEX
#        variables.  Default is PS output using BibTeX.
# make pdf - Compile as PDF regardless of the LATEX variable setting.
# make twoup - Compile as PS but giving output in 2-up format.
# make book - Compile as PS but giving output suitable for printing in
# 		        booklet form.  Send to the printer as a duplex job.
# make tidy	- Remove any auxiliary files created during the make process.
# make clean - As for make tidy but in addition remove the final output
# 		         files.
#
# Questions/comments to Anthony Youd (anthony.youd@newcastle.ac.uk).
#------------------------------------------------------------------------------
OBJECT		= thesis

# Set this variable to true if you are using BibTeX for your citations; set it
# to false otherwise.
BIBTEX		= true

# Set this variable to latex if you are including only PS and EPS figures in
# your thesis; the resulting output will be a PS file.  Set it to pdflatex if
# you are only including PDF, PNG, or JPG images; the resulting output will be
# a PDF file.
LATEX		= pdflatex

# Add list of files here to allow make to only build what is necessary.  Your
# master document should be listed first.
SOURCES		= $(OBJECT).tex $(wildcard *.tex) $(wildcard ./*/*.tex)

TMP=$(shell cat stats/compiled)

#---- IMPLICIT RULES ----------------------------------------------------------
.SUFFIXES: .tex .dvi .ps .pdf .ps.gz .bbl

.ps.ps.gz:
	gzip -c $*.ps > $*.ps.gz

.tex.pdf:
	$(LATEX) -shell-escape $* --enable-write18
	$(LATEX) -shell-escape $* --enable-write18
	echo "$(TMP) + 1" | bc > stats/compiled
	pdfinfo thesis.pdf | grep "Pages" | awk '{printf $$2}' > stats/pages
	pdftotext thesis.pdf - | LC_ALL=C  tr " " "\n" | grep -E "^[A-Za-z]+$$" | wc -l > stats/words
	pdftotext thesis.pdf - | LC_ALL=C  grep -oE "Figure [0-9]+.[0-9]+" | sort | uniq | wc -l > stats/figures
	git rev-list HEAD --count > stats/commits
	git log -1 --pretty=%B > stats/lastmessage

# Using pdflatex to compile.
.tex.bbl:
	$(LATEX) -shell-escape $* --enable-write18
	$(BSTINPUTS) bibtex $*

#------------------------------------------------------------------------------
# Using pdflatex to compile.
default: pdf

all: $(OBJECT).dvi ps

#------------------------------------------------------------------------------
ps: $(OBJECT).ps

pdf: $(OBJECT).pdf

twoup: $(OBJECT).ps
	psnup -n2 -Pa4 $(OBJECT).ps $(OBJECT).2up.ps

book: ps
	psbook $(OBJECT).ps book.ps
	psnup -n2 -Pa4 book.ps $(OBJECT).book.ps
	rm -f book.ps

#------------------------------------------------------------------------------
tidy:
	rm -f *.aux *.toc *.log *.out  \
	      *.bbl *.blg *.idx *.lot *.lof \
	      $(OBJECT)_dvi.* $(OBJECT)_pdf.* */*.aux
clean: tidy
	rm -f $(OBJECT).dvi $(OBJECT).pdf $(OBJECT)-figure*.pdf $(OBJECT)-figure*.dep $(OBJECT)-figure*.dpth $(OBJECT)-figure*.table $(OBJECT)-figure*.gnuplot $(OBJECT).ps

#---- DEPENDENCIES ------------------------------------------------------------
$(OBJECT).pdf: $(OBJECT).bbl $(OBJECT).tex $(SOURCES)
$(OBJECT).bbl: $(OBJECT).tex references.bib $(SOURCES)
$(OBJECT).ps: $(OBJECT).dvi
$(OBJECT).ps.gz: $(OBJECT).ps
