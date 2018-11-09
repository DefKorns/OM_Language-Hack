
MOD_NAME := Theme Randomizer
MOD_CREATOR := DefKorns
MOD_CATEGORY := UI
MOD_URL=`git config --get remote.origin.url`
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
	rsync -e ssh --progress --exclude 'rsync*' --exclude 'src' -avzzp out/* user@domain:/var/www/html/Hakchi_Themes/options_menu

clean:
	-rm -rf out/

.PHONY: clean
