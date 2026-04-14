# Modules Basics

Modules provide access to software that has already been installed for users.

## Start clean

``` bash
module reset
module list
```

## Search for software

``` bash
module spider python
module spider openmpi
```

If the workshop team want a concrete software example for the live system, replace the commands above with a specific
module known to be available on Isambard 3.

## Load something and inspect the environment

Example pattern:

``` bash
module load <module-name>
module list
which python
python --version
```

## Key idea

Try modules first. If the software you need is already provided, that is usually the simplest path.
