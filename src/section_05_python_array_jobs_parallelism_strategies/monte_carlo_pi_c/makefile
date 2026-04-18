CC      ?= mpicc
CFLAGS  ?= -O3 -mcpu=neoverse-v2 -std=c11 -Wall -Wextra -fopenmp
LDFLAGS ?=
LIBS    ?= -lm
BINS    = monte_carlo_pi_mpi_hybrid

.PHONY: all clean help

all: $(BINS)  ## build the MPI+OpenMP Monte Carlo Pi binary

%: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@ $(LIBS)

clean:  ## remove built binary
	$(RM) $(BINS)

.DEFAULT_GOAL = help
help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,parts,":.*##");targets[n]=parts[1];helps[n]=parts[2];l=length(targets[n]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,targets[i]":",helps[i]}' $(MAKEFILE_LIST)
