
MOD_NAME := Options Menu - Shonen Jump Language Hack
MOD_CREATOR := DefKorns
MOD_CATEGORY := User Interface
MOD_VER := Release_Candidate_4
MOD_URL=`git config --get remote.origin.url`
GIT_COMMIT := $(shell echo "`git rev-parse --short HEAD``git diff-index --quiet HEAD -- || echo '-dirty'`")
LANGUAGE=language_pack/language

MOD_FILENAME := $(shell basename ${MOD_URL} .git | cut -d':' -f2)

hmod: out/$(MOD_FILENAME).hmod
tar: out/$(MOD_FILENAME).tar.gz
zip: out/$(MOD_FILENAME).zip

all: hmod tar zip customlang scripts
deploy: customlang scripts upload

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
	cd temp/; tar -czf "../out/customlangs/"$$country".tar.gz" *; \
	cd .. && rm -r temp/ ; \
	done

scripts:
	cd language_pack/localization ; \
	tar -czf ../../out/localization.tar.gz *

upload:
	rm -f out/$(MOD_FILENAME).*
	rsync -e ssh --progress --exclude 'rsync*' --exclude 'src' -avzzp out/* user@host:/var/www/html/Hakchi_Themes/options_menu

clean:
	-rm -rf out/

.PHONY: clean
