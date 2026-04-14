# Internal Advertising Master Presentation

This sub-project creates the UoE presentation theme with a Pandoc + reveal.js deck.

## Commands

Build all HTMLs:

``` sh
make all
```

Serve:

``` sh
pixi run serve
```

Add visit <http://localhost:8001>.

## Editing workflow

Edit `assets/theme.css`.

## Notes

- reveal.js runtime is loaded from CDN.
- Custom presentation assets are local in `assets/`.
- Build task disables implicit figures to prevent image alt text captions from appearing on slides.
