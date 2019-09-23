# LaTex Makefile

FILE = note

#all: pdf view vim clean

pdf: $(FILE).tex
	pdflatex -no-shell-escape -interaction=nonstopmode $(FILE).tex

view: 
	evince $(FILE).pdf &

vim:
	apvlv $(FILE).pdf &

clean: 
	rm *.aux *-inc.* *.bbl *.blg *.bcf *.log *.nav *.out *.snm *.toc *.run.xml *.gp~ Makefile~ *.tex~ *.bib~
	@echo "all cleaned up"
