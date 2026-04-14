# Storage Worksheet

Use this as a short discussion or pair exercise while attendees are settling in.

## Questions

1.  Which location would you use for shell configuration files and small helper scripts?
2.  Which location would you use for files that need to be shared with other project members?
3.  Which location would you use for temporary job outputs or working data?
4.  Why is `$HOME` a bad place for large working datasets?
5.  Why is `$SCRATCHDIR` a bad place for anything you cannot afford to lose?

## Expected Answers

- `$HOME` is for config, scripts, and small personal files
- `$PROJECTDIR` is for shared project material
- `$SCRATCHDIR` is for temporary working data
- `$HOME` is limited and easy to fill accidentally
- scratch space is temporary working storage, not long-term storage

## Prompt for the Room

“Before running anything expensive, ask yourself: does this belong in home, project, or scratch?”
