# LaTex Makefile

FILE = skk

#all: pdf view vim clean

pdf: $(FILE).tex
	pdflatex $(FILE).tex

view: 
	evince $(FILE).pdf &

vim:
	apvlv $(FILE).pdf &

clean: 
	rm *.aux *-inc.* *.bbl *.blg *.bcf *.log *.nav *.out *.snm *.toc *.run.xml *.gp~ Makefile~ *.tex~ *.bib~
	@echo "all cleaned up"
