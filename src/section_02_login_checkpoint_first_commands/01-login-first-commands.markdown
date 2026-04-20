## Login checkpoint and first commands {#login-checkpoint-and-first-commands .shell-slide}

::: slide-subtitle
Ten minutes: short orientation, then try-time, then questions
:::

:::: shell-grid
::: shell-text
Quick checkpoint: does everyone have a shell prompt on Isambard 3?

- If you do **not** have a prompt yet, raise a hand now and a helper will stay with you
- Anyone still stuck on login can follow along on-screen
- Editor route for today: open VS Code in the browser via the BriCS **browser tunnel** guide when we need an editor; if
  you already brought desktop VS Code, vim, or another editor fully set up, keep using that

We are going to cover **three small things**: where you can put files, how to get at pre-built software, and a shared
list of commands you will run in a moment.
:::
::::

::: notes
- Open with: "If you already have a shell prompt on Isambard 3, stay with me. If you do not, raise a hand now."
- Tell helpers: "Please pick up anyone without a prompt and keep going with them in parallel; do not wait for the room."
- If someone is still blocked after the first minute, say: "Follow along on the projector for now; we will mop up the
  login issue in parallel."
- Spoken editor signpost: "When we need to edit files later, the default taught route is VS Code in the browser via the
  BriCS tunnel guide. If you already came with desktop VS Code, vim, or another editor working, that is fine too."
- Close the slide with: "This is just a quick bridge into the first Slurm job: storage, modules preview, then a short
  command list for you to try."
:::

## Storage: what goes where {#storage-what-goes-where .shell-slide}

::: slide-subtitle
Three storage areas, three jobs --- pick the right one before you write
:::

:::: shell-grid
::: shell-text
  Variable        Quota     Purpose                                       Lifetime
  --------------- --------- --------------------------------------------- ---------------------------------------
  `$HOME`         100 GiB   Shell config, scripts, submission, job logs   Kept until project end
  `$PROJECTDIR`   20 TiB    Shared project material (collaborators)       Kept until project end
  `$SCRATCHDIR`   5 TiB     Working data and job outputs                  **Purged after 60 days** of no access

**None of these are backed up.** Storage on BriCS is *working* storage --- keep an off-system copy of anything you
cannot afford to lose.

Rule of thumb: before writing anything, ask whether it belongs in home, project, or scratch.

Full details (paths, `$LOCALDIR`, `$PROJECTDIR_PUBLIC`, quota checks):
<https://docs.isambard.ac.uk/user-documentation/information/system-storage/>
:::
::::

::: notes
- Storage was the most common follow-up question in previous workshops
- Lead with "nothing is backed up" --- this is the single most important takeaway
- `$SCRATCHDIR` purge policy is 60 days since last access, not 60 days since creation
- \$LOCALDIR and \$PROJECTDIR_PUBLIC exist but are out of scope here; defer to the docs link
:::

## Try these now {#try-these-now .shell-slide}

::: slide-subtitle
Five minutes --- helpers are circulating, raise a hand if anything is unclear
:::

::::: columns
::: {.column width="50%"}
``` bash
# Who and where am I?
whoami
hostname
pwd

# Storage areas
echo $HOME
echo $PROJECTDIR
echo $SCRATCHDIR

# Move between them
cd $PROJECTDIR
pwd
cd
pwd
```
:::

::: {.column width="50%"}
``` bash
# Scratch quota
# (same form works for $HOME or $PROJECTDIR)
lfs quota -hp \
  $(lfs project -d $SCRATCHDIR | awk '{print $1}') \
  $SCRATCHDIR

# Preview the module system
module list
module reset
module list
module avail python
```

Stretch: pipe `module avail` through `grep -i` to look for a tool you already use.
:::
:::::

::: slide-note
Quota form from the [Isambard 3 storage
docs](https://docs.isambard.ac.uk/user-documentation/information/system-storage/) --- works against any of the three
areas by substituting the variable.
:::

## Discussion {#section-2-discussion .qa-slide}

::: qa-mark
Discussion
:::

::: qa-subtitle
Questions? Comments? Anything you found interesting?
:::
