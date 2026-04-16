.DEFAULT_GOAL = help

SHELL = /usr/bin/env bash

INFILES = $(wildcard src/bin/*.sh)
OUTFILES = $(patsubst src/bin/%.sh,%.sh,$(INFILES))
LIBS = $(wildcard src/lib/*.sh)

all: $(OUTFILES)  ## build all scripts

%.sh: src/bin/%.sh $(LIBS)
	src/compile.sh $< > $@
	chmod +x $@

print-%:
	$(info $* = $($*))

help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,cols[n],":.*##");l=length(cols[n][1]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,cols[i][1]":",cols[i][2]}' $(MAKEFILE_LIST)
