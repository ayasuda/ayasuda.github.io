INDEX = index.html

SRCDIR =./src
PAGEDIR =./pages

SRCS := $(shell find $(SRCDIR) -name '*.md')
PAGES := $(SRCS:.md=.html)

TEMPLATE=./conf/html5_template.html

PANDOC = pandoc
PANDOCFLAGS = -f markdown -t html --template=$(TEMPLATE)

all: $(INDEX)

$(INDEX): $(PAGEDIR) conf/index.html.erb
	ruby ./conf/make_index.rb > index.html

$(PAGEDIR): $(PAGES)
	$(MKDIR_P) $(PAGEDIR)
	$(CP) $(SRCDIR)/*.html $(PAGEDIR)

$(PAGES): $(TEMPLATE)

$(PAGES): %.html: %.md
	$(PANDOC) $(PANDOCFLAGS) -o $@ $<

.PHONY: clean
clean:
	rm $(PAGES)

.PHONY: clean_all
clean_all:
	rm -r $(PAGEDIR)
	rm $(PAGES)


MKDIR_P = mkdir -p
CP = cp
