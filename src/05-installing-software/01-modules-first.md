# Modules First

The workshop decision order is:

1. check whether the software is already available as a module
2. if not, create an isolated user-managed environment
3. if things become highly bespoke, take it offline after the workshop

## Start clean

```bash
module reset
module list
```

## Search for software

```bash
module spider python
module spider miniconda
```

You can also use:

```bash
module avail | head -n 20
```

## Load a module

Replace `<module-name>` with a module known to be available on Isambard 3.

```bash
module load <module-name>
module list
which python
python --version
```

## Reset again

```bash
module reset
```

## Key teaching points

- Prefer modules when they already provide what you need
- `module reset` is the quickest way back to a known state
- Avoid building up a mysterious shell environment during troubleshooting
