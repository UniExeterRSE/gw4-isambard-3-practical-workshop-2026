# Storage Check

Confirm you can move around the three main storage areas safely.

## Inspect the paths

``` bash
echo $HOME
echo $PROJECTDIR
echo $SCRATCHDIR
```

## Move to project storage

``` bash
cd $PROJECTDIR
pwd
```

## Return home

``` bash
cd
pwd
```

## Optional quota checks

The exact quota commands can vary by filesystem. If the workshop team want a live quota check, add the site-appropriate
command here before delivery.

Questions:

1.  Which of these locations is best for shared workshop files?
2.  Which of these locations should not be treated as permanent storage?
