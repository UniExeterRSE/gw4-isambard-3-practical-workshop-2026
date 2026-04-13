MD = $(shell find . -type f -name "*.md" | sort)
HTML = $(MD:.md=.html)
PANDOC_ARGS = \
	-f markdown-implicit_figures \
	-s \
	-t revealjs \
	-V center=false \
	-V css=/assets/theme.css \
	-V hash=true \
	-V height=1080 \
	-V margin=0.04 \
	-V maxScale=2.0 \
	-V minScale=0.1 \
	-V slideNumber=true \
	-V theme=white \
	-V transition=slide \
	-V width=1920

all: assets tree html  ## Build all HTML files and the index.html tree

assets:  ## Build assets
	$(MAKE) -C assets all

tree: index.html  ## Build the index.html tree
index.html: html
	command tree -H ./ -P '*.html' --prune -o $@

html: $(HTML)
%.html: %.md
	pandoc $(PANDOC_ARGS) -o $@ $<

.DEFAULT_GOAL = help
.PHONY: help
help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,parts,":.*##");targets[n]=parts[1];helps[n]=parts[2];l=length(targets[n]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,targets[i]":",helps[i]}' $(MAKEFILE_LIST)
