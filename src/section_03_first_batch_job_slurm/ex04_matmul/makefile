CC     ?= cc
CFLAGS ?= -O3 -mcpu=neoverse-v2 -std=c11 -Wall -Wextra

.DEFAULT_GOAL = all

.PHONY: all clean help

all: matmul_dgemm matmul_sgemm matmul_naive  ## build the BLAS (double + single precision) and naive triple-loop binaries

matmul_dgemm: matmul.c  ## build the cblas_dgemm (double precision) binary
	$(CC) $(CFLAGS) -o $@ $<

matmul_sgemm: matmul.c  ## build the cblas_sgemm (single precision) binary
	$(CC) $(CFLAGS) -DUSE_SGEMM -o $@ $<

matmul_naive: matmul.c  ## build the naive ikj triple-loop binary (double precision, no BLAS)
	$(CC) $(CFLAGS) -DUSE_NAIVE -o $@ $<

clean:  ## remove built binaries
	rm -f matmul_dgemm matmul_sgemm matmul_naive

help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,parts,":.*##");targets[n]=parts[1];helps[n]=parts[2];l=length(targets[n]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,targets[i]":",helps[i]}' $(MAKEFILE_LIST)
