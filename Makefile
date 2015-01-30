# Original makefile from https://github.com/martinthomson/i-d-template

# Edited by wkumari to remove a bunch of the extra stuff I'll never use.

# The following tools are used by this file.
# All are assumed to be on the path, but you can override these
# in the environment, or command line.

# Mandatory:
#   https://pypi.python.org/pypi/xml2rfc
xml2rfc ?= xml2rfc

# If you are using markdown files:
#   https://github.com/cabo/kramdown-rfc2629
kramdown-rfc2629 ?= kramdown-rfc2629

# If you are using outline files:
#   https://github.com/Juniper/libslax/tree/master/doc/oxtradoc
oxtradoc ?= oxtradoc.in

# For sanity checkout your draft:
#   https://tools.ietf.org/tools/idnits/
idnits ?= idnits

# For diff:
#   https://tools.ietf.org/tools/rfcdiff/
rfcdiff ?= rfcdiff --browse

# For generating PDF:
#   https://www.gnu.org/software/enscript/
enscript ?= enscript
#   http://www.ghostscript.com/
ps2pdf ?= ps2pdf 


## Work out what to build

draft := $(basename $(lastword $(sort $(wildcard draft-*.xml)) $(sort $(wildcard draft-*.org)) $(sort $(wildcard draft-*.md))))

ifeq (,$(draft))
$(warning No file named draft-*.md or draft-*.xml or draft-*.org)
$(error Read README.md for setup instructions)
endif

draft_type := $(suffix $(firstword $(wildcard $(draft).md $(draft).org $(draft).xml)))

## Targets

.PHONY: latest txt html pdf submit diff clean update ghpages

latest: txt html
txt: $(draft).txt
html: $(draft).html
pdf: $(draft).pdf


idnits: $(draft).txt
	$(idnits) $<


clean:
	-rm -f $(draft).{txt,html,pdf} index.html
	-rm -f $(draft)-[0-9][0-9].{xml,md,org,txt,html,pdf}
	-rm -f *.diff.html
ifneq (.xml,$(draft_type))
	-rm -f $(draft).xml
endif

## diff

diff:
	git diff $(draft).txt


commit: $(draft).txt
	@echo "Making README.md and committing and pushing to github. Run 'make tag' to add and push a tag."
	@echo '**Important:** Read CONTRIBUTING.md before submitting feedback or contributing' > README.md
	@echo \`\`\` >> README.md
	@cat $(draft).txt >> README.md
	@echo \`\`\` >> README.md
	read -p "Commit message: " msg; \
	git commit -a -m "$$msg";
	@git push

tag:
	@echo "Current tags:"
	git tag
	@read -p "Tag message (e.g: Version-00): " tag; \
	git tag -a $$tag -m $$tag
	@git push --tags

## Recipes

.INTERMEDIATE: $(draft).xml
%.xml: %.md
	$(kramdown-rfc2629) $< > $@

%.xml: %.org
	$(oxtradoc) -m outline-to-xml -n "$@" $< > $@

%.txt: %.xml
	$(xml2rfc) $< -o $@ --text

%.html: %.xml
	$(xml2rfc) $< -o $@ --html

%.pdf: %.txt
	$(enscript) --margins 76::76: -B -q -p - $^ | $(ps2pdf) - $@


## Update the gh-pages branch with useful files


# Only run upload if we are local or on the master branch
IS_LOCAL := $(if $(TRAVIS),,true)
ifeq (master,$(TRAVIS_BRANCH))
IS_MASTER := $(findstring false,$(TRAVIS_PULL_REQUEST))
else
IS_MASTER :=
endif

index.html: $(draft).html
	cp $< $@

ghpages: index.html $(draft).txt
ifneq (,$(or $(IS_LOCAL),$(IS_MASTER)))
	mkdir $(GHPAGES_TMP)
	cp -f $^ $(GHPAGES_TMP)
	git clean -qfdX
ifeq (true,$(TRAVIS))
	git config user.email "ci-bot@example.com"
	git config user.name "Travis CI Bot"
	git checkout -q --orphan gh-pages
	git rm -qr --cached .
	git clean -qfd
	git pull -qf origin gh-pages --depth=5
else
	git checkout gh-pages
	git pull
endif
	mv -f $(GHPAGES_TMP)/* $(CURDIR)
	git add $^
	if test `git status -s | wc -l` -gt 0; then git commit -m "Script updating gh-pages."; fi
ifneq (,$(GH_TOKEN))
	@echo git push https://github.com/$(TRAVIS_REPO_SLUG).git gh-pages
	@git push https://$(GH_TOKEN)@github.com/$(TRAVIS_REPO_SLUG).git gh-pages
endif
	-git checkout -qf "$(GIT_ORIG)"
	-rm -rf $(GHPAGES_TMP)
endif
