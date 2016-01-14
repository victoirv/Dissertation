COMP=pdflatex
BIB=bibtex
TEX=Dissertation

all: 
	$(COMP) $(TEX).tex
	$(BIB) $(TEX)
	$(COMP) $(TEX).tex
	$(COMP) $(TEX).tex

clean:
	rm -f $(TEX).{ps,pdf,log,aux,out,dvi,bbl,blg,lof,lot,tks,toc}
	rm -f *.{log,aux} #Avoid removing ps and pdf, but get rid of chapter build files

