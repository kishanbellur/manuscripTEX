# Makefile
# Simple version of the Makefile used to systematically compile a .tex file into a .pdf using latex accoording to given instructions.

####### INPUTS #########################
TEX_BASENAME=XXX
BIBMASTER=$(HOME)/MEGA/Papers/KSB_master_zotero.bib
##############################################

# Defining other basenames
TEX_BASENAME_NEW_EXTN=$(shell find -name $(TEX_BASENAME)'*.tex' | sort -V | tail -1)
TEX_BASENAME_NEW=$(shell basename $(TEX_BASENAME_NEW_EXTN) .tex)
TEX_NEW_V=$(shell echo $(TEX_BASENAME_NEW) | sed 's/.*_//')
TEX_NEW_VNUM=$(shell echo $(TEX_NEW_V) | sed "s/[^0-9]//g")
$(eval TEX_NEW_VNUM_INC=$(shell echo $$(($(TEX_NEW_VNUM)+1))))

TEX_BASENAME_OLD_EXTN=$(shell find -name $(TEX_BASENAME)'*.tex' | sort -V | tail -2 | head -1)
TEX_BASENAME_OLD=$(shell basename $(TEX_BASENAME_OLD_EXTN) .tex)
TEX_OLD_V=$(shell echo $(TEX_BASENAME_OLD) | sed 's/.*_//')
TEX_OLD_VNUM=$(shell echo $(TEX_BASENAME_OLD) | sed "s/[^0-9]//g")
$(eval TEX_OLD_VNUM_DEC=$(shell echo $$(($(TEX_OLD_VNUM)-1))))

$(info TEX_BASENAME is ${TEX_BASENAME})
#$(info TEX_BASENAME_NEW_EXTN is ${TEX_BASENAME_NEW_EXTN})
#$(info TEX_BASENAME_NEW is ${TEX_BASENAME_NEW})
#$(info TEX_BASENAME_OLD is ${TEX_BASENAME_OLD})
#$(info TEX_DIFF is ${TEX_DIFF})
#$(info TEX_NEW_V is ${TEX_NEW_V})
#$(info TEX_OLD_V is ${TEX_OLD_V})
$(info TEX_NEW_VNUM is ${TEX_NEW_VNUM})
#$(info TEX_OLD_VNUM is ${TEX_OLD_VNUM})
#$(info TEX_NEW_VNUM_INC is ${TEX_NEW_VNUM_INC})
$(info TEX_OLD_VNUM_DEC is ${TEX_OLD_VNUM_DEC})

TEX_DIFF=${TEX_BASENAME}_MARKUP_${TEX_OLD_V}_to_${TEX_NEW_V}
TEX_DIFF_OLD=${TEX_BASENAME}_MARKUP_v${TEX_OLD_VNUM_DEC}_to_v${TEX_OLD_VNUM}
$(info TEX_DIFF_OLD is ${TEX_DIFF_OLD})

TEX_RESPONSE=${TEX_BASENAME}_${TEX_NEW_V}_RESPONSE
TEX_SUPPLEMENT=${TEX_BASENAME}_${TEX_NEW_V}_SUPPLEMENT

# Obtain current time
DATETIME = $(shell date +"%m%d%Y_%H%M%S")

# make/make all
all: 
	make clean
	make pdf
	make bib
	make pdf
	make pdf
	make clean

bib: $(TEX_BASENAME_NEW).tex
	cp $(BIBMASTER) $(TEX_BASENAME).bib
	bibexport -o $(TEX_BASENAME).bib $(TEX_BASENAME_NEW).aux
	bibtex $(TEX_BASENAME_NEW)

pdf: $(TEX_BASENAME_NEW).tex
	pdflatex $(TEX_BASENAME_NEW)


# Clean up
clean:
	@echo
	@echo " Removing temporary files"
	@echo
	rm -f $(TEX_BASENAME_NEW).aux $(TEX_BASENAME_NEW).blg $(TEX_BASENAME_NEW).dvi $(TEX_BASENAME_NEW).log $(TEX_BASENAME_NEW).out $(TEX_BASENAME_NEW).ps $(TEX_BASENAME_NEW).spl $(TEX_BASENAME_NEW)*.bib $(TEX_BASENAME_NEW)*.bbl
	@echo
	rm -f $(TEX_BASENAME_OLD).aux $(TEX_BASENAME_OLD).blg $(TEX_BASENAME_OLD).dvi $(TEX_BASENAME_OLD).log $(TEX_BASENAME_OLD).out $(TEX_BASENAME_OLD).ps $(TEX_BASENAME_OLD).spl $(TEX_BASENAME_OLD).bbl 
	@echo
	rm -f $(TEX_DIFF).aux $(TEX_DIFF).blg $(TEX_DIFF).dvi $(TEX_DIFF).log $(TEX_DIFF).out $(TEX_DIFF).ps $(TEX_DIFF).spl $(TEX_DIFF).bbl $(TEX_DIFF)*.bib $(TEX_DIFF).tex
	@echo
	rm -f *.bib-save*
	
# Diff
markup: $(TEX_BASENAME_NEW).tex $(TEX_BASENAME_OLD).tex
	latexdiff $(TEX_BASENAME_OLD).tex $(TEX_BASENAME_NEW).tex > $(TEX_DIFF).tex
	#cp $(TEX_BASENAME_NEW).bib $(TEX_DIFF).bib
	pdflatex $(TEX_DIFF)
	bibtex $(TEX_DIFF)
	pdflatex $(TEX_DIFF)
	pdflatex $(TEX_DIFF)
	@echo
	rm -f $(TEX_DIFF).aux $(TEX_DIFF).blg $(TEX_DIFF).dvi $(TEX_DIFF).log $(TEX_DIFF).out $(TEX_DIFF).ps $(TEX_DIFF).spl $(TEX_DIFF).bbl $(TEX_DIFF)*.bib $(TEX_DIFF).tex $(TEX_DIFF).bbl

# Review Response
response: $(TEX_RESPONSE).tex
	pdflatex $(TEX_RESPONSE)
	pdflatex $(TEX_RESPONSE)
	#bibtex $(TEX_RESPONSE)
	#pdflatex $(TEX_RESPONSE)
	#pdflatex $(TEX_RESPONSE)
	rm -f $(TEX_RESPONSE).aux $(TEX_RESPONSE).blg $(TEX_RESPONSE).dvi $(TEX_RESPONSE).log $(TEX_RESPONSE).out $(TEX_RESPONSE).ps $(TEX_RESPONSE).spl $(TEX_RESPONSE).bbl

# snapshot
snapshot:
	@echo
	@echo " Making a snapshot of all files and folders"
	mkdir -p Snapshots

	if [ $(TEX_NEW_VNUM) -gt 1 ] ; then \
        	rm -rf $(TEX_DIFF_OLD).pdf ;\
		rm -rf $(TEX_BASENAME)_v$(TEX_OLD_VNUM_DEC).* ;\
		rm -rf $(TEX_BASENAME_OLD).* ;\
    	fi

	rsync -a --exclude 'Snapshots' --exclude '*_review' --exclude 'old' --exclude '*.dat' --exclude '*.m' --exclude '*.gnu' --exclude '*.sh' --exclude 'backup' --exclude '*.zip' ./ $(TEX_BASENAME_NEW)_$(DATETIME)/
	zip -qr $(TEX_BASENAME_NEW)_$(DATETIME).zip $(TEX_BASENAME_NEW)_$(DATETIME)
	mv $(TEX_BASENAME_NEW)_$(DATETIME).zip ./Snapshots/
	rm -rf $(TEX_BASENAME_NEW)_$(DATETIME)
	@echo
	cp $(TEX_BASENAME_NEW).tex $(TEX_BASENAME)_v$(TEX_NEW_VNUM_INC).tex

		
	
# supplement
supplement: $(TEX_SUPPLEMENT).tex
	pdflatex $(TEX_SUPPLEMENT)
	pdflatex $(TEX_SUPPLEMENT)
	rm -f $(TEX_SUPPLEMENT).aux $(TEX_SUPPLEMENT).blg $(TEX_SUPPLEMENT).dvi $(TEX_SUPPLEMENT).log $(TEX_SUPPLEMENT).out $(TEX_SUPPLEMENT).ps $(TEX_SUPPLEMENT).spl
