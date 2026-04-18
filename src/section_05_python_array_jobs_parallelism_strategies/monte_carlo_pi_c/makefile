CC      = mpicc
CFLAGS  = -O3 -march=native -fopenmp -std=c11
LDFLAGS =
LIBS    = -lm

# conda-forge mpicc needs the real CC pointed at the system compiler.
export OMPI_CC = gcc

SRCS = monte_carlo_pi_mpi_hybrid.c
BINS = $(SRCS:.c=)

.PHONY: all clean

all: $(BINS)

%: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@ $(LIBS)

clean:
	$(RM) $(BINS)
