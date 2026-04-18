CC     	?= cc
CFLAGS 	?= -O3 -mcpu=neoverse-v2 -std=c11 -Wall -Wextra
PROGS  	?= matmul_dgemm matmul_sgemm matmul_naive matmul_naive_flt

.PHONY: all clean help

all: $(PROGS)  ## build all four matmul binaries

%: %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:  ## remove built binaries
	rm -f $(PROGS)

.DEFAULT_GOAL = help
.PHONY: help
help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,parts,":.*##");targets[n]=parts[1];helps[n]=parts[2];l=length(targets[n]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,targets[i]":",helps[i]}' $(MAKEFILE_LIST)
