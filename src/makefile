MARKDOWN = $(shell find . -type f -name '*.markdown' | sort)
HTML = $(MARKDOWN:.markdown=.html)
PANDOC_ARGS = \
	--mathjax \
	-f markdown \
	-s \
	-t revealjs \
	-V center=false \
	-V hash=true \
	-V height=1080 \
	-V margin=0.04 \
	-V maxScale=2.0 \
	-V minScale=0.1 \
	-V slideNumber=true \
	-V theme=white \
	-V transition=slide \
	-V width=1920

.PHONY: all assets tree html clean
all: assets tree html  ## Build all HTML files and the index.html tree

assets:  ## Build assets
	$(MAKE) -C assets all

tree: index.html  ## Build the index.html tree
index.md: html
	python -c 'import pathlib; print("\n".join(sorted(f"- [{p}]({p})" for p in pathlib.Path(".").rglob("*.html") if p.stem not in {"index", "template"})))' > $@
index.html: index.md
	pandoc -s -o $@ $< -M title="Isambard 3 Practical Workshop"

html: $(HTML)
%.html: %.markdown
	pandoc $(PANDOC_ARGS) -V css=$(shell python -c "from pathlib import Path; import os; print(os.path.relpath('assets/theme.css', start=str(Path('$(dir $@)')) or '.'))") -o $@ $<

clean:  ## Clean all generated files
	rm -f $(HTML) index.html
	$(MAKE) -C assets clean

print-%:
	$(info $* = $($*))

.DEFAULT_GOAL = help
.PHONY: help
help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,parts,":.*##");targets[n]=parts[1];helps[n]=parts[2];l=length(targets[n]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,targets[i]":",helps[i]}' $(MAKEFILE_LIST)
