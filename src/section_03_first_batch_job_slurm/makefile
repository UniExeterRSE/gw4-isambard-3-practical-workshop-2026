CC      ?= gcc
CFLAGS  ?= -O3 -mcpu=neoverse-v2 -std=c11 -Wall -Wextra
LDFLAGS ?=
LDLIBS  ?= -lm

.DEFAULT_GOAL = all

.PHONY: all openmp clean help

all: matmul  ## build the single-threaded matmul binary

matmul: matmul.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(LDLIBS)

openmp: matmul_omp  ## build an OpenMP-parallel matmul_omp binary (stretch)

matmul_omp: matmul.c
	$(CC) $(CFLAGS) -fopenmp -o $@ $< $(LDFLAGS) $(LDLIBS)

clean:  ## remove built binaries
	rm -f matmul matmul_omp

help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,parts,":.*##");targets[n]=parts[1];helps[n]=parts[2];l=length(targets[n]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,targets[i]":",helps[i]}' $(MAKEFILE_LIST)
