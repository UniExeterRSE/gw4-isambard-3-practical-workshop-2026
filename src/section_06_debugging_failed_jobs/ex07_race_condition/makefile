CC     ?= cc
CFLAGS ?= -O2 -mcpu=neoverse-v2 -std=c11 -Wall -Wextra -fopenmp

.PHONY: all clean

all: race_condition  ## build the race condition demo

race_condition: race_condition.c
	$(CC) $(CFLAGS) -o $@ $<

clean:  ## remove built binary
	rm -f race_condition
