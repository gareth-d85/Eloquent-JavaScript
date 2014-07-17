all: html tex

CHAPTERS := 00_intro 01_values 02_program_structure 03_functions 04_data 05_higher_order 06_object \
  07_elife 08_error 09_regexp 10_modules 11_language 12_browser 13_dom 14_event 15_game 16_canvas \
  17_http 18_forms 19_paint 20_node 21_skillsharing

.SECONDARY: $(foreach CHAP,$(CHAPTERS),tex/$(CHAP).db)

html: $(foreach CHAP,$(CHAPTERS),html/$(CHAP).html) html/js/exercise_data.js code/skillsharing.zip code/solutions/20_4_a_public_space_on_the_web.zip

html/%.html: %.txt asciidoc_html.conf
	PATH=node_modules/codemirror/bin:$(PATH) asciidoc -f asciidoc_html.conf --backend=html5 -o $@ $<
	node bin/build_code.js $<

html/js/exercise_data.js: $(foreach CHAP,$(CHAPTERS),$(CHAP).txt) code/solutions/*
	node bin/get_exercises.js > html/js/exercise_data.js

code/skillsharing.zip: html/21_skillsharing.html
	rm -f $@
	cd code; zip skillsharing.zip skillsharing/*.js* skillsharing/public/*.*

code/solutions/20_4_a_public_space_on_the_web.zip: $(wildcard code/solutions/20_4_a_public_space_on_the_web/*)
	rm -f $@
	cd code/solutions; zip 20_4_a_public_space_on_the_web.zip 20_4_a_public_space_on_the_web/*

tex: $(foreach CHAP,$(CHAPTERS),tex/$(CHAP).tex)

tex/%.tex: %.txt asciidoc_latex.conf
	cat $< | node bin/pre_latex.js | asciidoc -f asciidoc_latex.conf --backend=latex -o - - | node bin/clean_latex.js > $@

test: html
	@for F in $(CHAPTERS); do echo Testing $$F:; node bin/run_tests.js $$F.txt; done
	@! grep '[a-zA-Z0-9]_[—“”‘’]\|[—“”‘’]_[a-zA-Z0-9]\|[a-zA-Z0-9]`—\|[a-zA-Z0-9]`[a-zA-Z0-9]' *.txt
	@echo Done.

book.pdf: $(foreach CHAP,$(CHAPTERS),tex/$(CHAP).tex)
	cd tex/book && xelatex book.tex
	cd tex/book && xelatex book.tex
	mv tex/book/book.pdf .
