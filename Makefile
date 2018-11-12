
MOD_NAME := Options Menu - Language Hack
MOD_CREATOR := DefKorns
MOD_CATEGORY := User Interface
MOD_VER := Release_Candidate_4
MOD_URL=`git config --get remote.origin.url`
GIT_COMMIT := $(shell echo "`git rev-parse --short HEAD``git diff-index --quiet HEAD -- || echo '-dirty'`")
LANGUAGE=language_pack/language
LANGUAGENES=language_pack/languagenes
LANGUAGESNES=language_pack/languagesnes

MOD_FILENAME := $(shell basename ${MOD_URL} .git | cut -d':' -f2)

hmod: out/$(MOD_FILENAME).hmod
tar: out/$(MOD_FILENAME).tar.gz
zip: out/$(MOD_FILENAME).zip

all: hmod tar zip customlang customlangsnes shonen snes
deploy: customlang customlangsnes shonen snes upload

out/$(MOD_FILENAME).hmod:
	rm -rf out/
	mkdir -p out/ temp/
	rsync -a mod/ temp/ --links --delete

	printf "%s\n" \
	"---" \
	"Name: $(MOD_NAME)" \
	"Creator: $(MOD_CREATOR)" \
	"Category: $(MOD_CATEGORY)" \
	"Version: $(MOD_VER)" \
	"Built on: $(shell date +"%A, %d %b %Y - %T")" \
	"Git commit: $(GIT_COMMIT)" \
	"---" > temp/readme.md
	
	sed 1d mod/readme.md >> temp/readme.md

	cd temp/; tar -czf "../$@" *
	rm -r temp/
	touch "$@"

out/$(MOD_FILENAME).tar.gz:
	mkdir -p out/ temp/
	rsync -a mod/etc/options_menu/ temp/ --links --delete

	cd temp/; tar -czf "../$@" *
	rm -r temp/
	touch "$@"

out/$(MOD_FILENAME).zip:
	mkdir -p out/ temp/
	rsync -a mod/etc/options_menu/ temp/ --links --delete

	cd temp/; zip -r "../$@" *
	rm -r temp/
	touch "$@"

customlang:
	mkdir -p out/customlangs temp/
	find $(LANGUAGE)/. -mindepth 1 -maxdepth 1 -type d | xargs -n 1 basename | while IFS= read -r country; do \
	rsync -a $(LANGUAGE)/$$country/ temp/ --links --delete ; \
	cd temp/; tar -czf "../out/customlangs/shonen"$$country".tar.gz" *; \
	cd .. && rm -r temp/ ; \
	done

customlangsnes:
	mkdir -p out/customlangs temp/
	find $(LANGUAGESNES)/. -mindepth 1 -maxdepth 1 -type d | xargs -n 1 basename | while IFS= read -r country; do \
	rsync -a $(LANGUAGESNES)/$$country/ temp/ --links --delete ; \
	cd temp/; tar -czf "../out/customlangs/snes"$$country".tar.gz" *; \
	cd .. && rm -r temp/ ; \
	done

customlangnes:
	mkdir -p out/customlangs temp/
	find $(LANGUAGENES)/. -mindepth 1 -maxdepth 1 -type d | xargs -n 1 basename | while IFS= read -r country; do \
	rsync -a $(LANGUAGENES)/$$country/ temp/ --links --delete ; \
	cd temp/; tar -czf "../out/customlangs/nes"$$country".tar.gz" *; \
	cd .. && rm -r temp/ ; \
	done

shonen:
	cd language_pack/localization ; \
	tar -czf ../../out/shonenlocalization.tar.gz *

snes:
	cd language_pack/sneslocalization ; \
	tar -czf ../../out/sneslocalization.tar.gz *

nes:
	cd language_pack/neslocalization ; \
	tar -czf ../../out/neslocalization.tar.gz *

upload:
	rm -f out/$(MOD_FILENAME).*
	rsync -e ssh --progress --exclude 'rsync*' --exclude 'src' -avzzp out/* defkorns@hakchicloud.com:/var/www/html/Hakchi_Themes/options_menu

clean:
	-rm -rf out/

.PHONY: clean
