# First Commands on Isambard 3

Run these commands one by one and discuss what each tells you.

```bash
whoami
hostname
pwd
echo $HOME
echo $PROJECTDIR
echo $SCRATCHDIR
```

Questions to answer:

1. Which machine are you currently on?
2. What directory did you start in?
3. Which storage locations are already available as environment variables?

Now inspect the module environment:

```bash
module avail | head
module list
module reset
module list
```

Questions to answer:

1. What modules were loaded before `module reset`?
2. Why is `module reset` useful before following workshop instructions?
3. Why is `module avail | head` only a preview, not the full list?

Stretch:

```bash
module spider python
module spider gcc
```
