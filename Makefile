INDEX := publish/index.html
TEMPLATE := ./template.html

PUBLISH_DIR := publish

HTML_CC     := cp
HTML_OUTDIR := $(PUBLISH_DIR)
HTML_SRCDIR := html
HTML_SRCS   := $(wildcard $(HTML_SRCDIR)/*.html)
HTML_PAGES  := $(addprefix $(HTML_OUTDIR)/, $(notdir $(HTML_SRCS)))

MARKDOWN_CC  := pandoc
MARKDOWN_OPT := -f markdown -t html5 --template=$(TEMPLATE) $(MARKDOWN_VARIABLES)
MARKDOWN_VARIABLES := -V host=http://localhost:3000

MARKDOWN_OUTDIR := $(PUBLISH_DIR)/pages
MARKDOWN_SRCDIR := src
MARKDOWN_SRCS := $(wildcard $(MARKDOWN_SRCDIR)/*.md)
MARKDOWN_PAGES := $(addprefix $(MARKDOWN_OUTDIR)/, $(notdir $(patsubst %.md,%.html,$(MARKDOWN_SRCS))))

CSS_CC  := node_modules/.bin/postcss
CSS_OPT := style/style.css -c postcss.config.js

CSS_OUT    := publish/assets/style.css
CSS_SRCDIR := style
CSS_SRCS   := $(wildcard $(CSS_SRCDIR)/*.css)

.PHONY: all
all: $(MARKDOWN_OUTDIR) $(INDEX)
	@echo "done"

.PHONY: clean
clean:
	rm -rf $(MARKDOWN_OUTDIR)
	rm $(CSS_OUT)
	rm $(INDEX)
	rm -rf $(PUBLISH)

.PHONY: test
test: $(CSS_OUT)

$(INDEX): index.html $(HTML_PAGES) $(MARKDOWN_PAGES) $(CSS_OUT)
	cp index.html publish/index.html

$(PUBLISH_DIR):
	mkdir -p $(PUBLISH_DIR)

$(HTML_OUTDIR)/%.html:$(HTML_SRCDIR)/%.html
	$(HTML_CC) $< $@

$(MARKDOWN_OUTDIR): $(PUBLISH_DIR)
	mkdir -p $(MARKDOWN_OUTDIR)

$(MARKDOWN_OUTDIR)/%.html:$(MARKDOWN_SRCDIR)/%.md $(TEMPLATE)
	$(MARKDOWN_CC) $(MARKDOWN_OPT) -o $@ $<

$(CSS_OUT): $(CSS_SRCS)
	$(CSS_CC) $(CSS_OPT) -o $(CSS_OUT)
