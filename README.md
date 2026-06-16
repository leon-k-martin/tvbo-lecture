# TVB-O Lecture

Standalone [reveal.js](https://revealjs.com/) slide deck —
**"Introduction to the TVB modeling framework and The Virtual Brain Ontology"**
(Summer School 2026).

## Build

```bash
make render        # render the deck → index.html (uses the _freeze cache)
make preview       # live-reloading preview
make help          # list all targets
```

The entry point is `index.qmd`, so the build is `index.html` (open it directly, or
deploy the folder as a static site). Equivalently, `quarto render` / `quarto preview`.

The deck renders directly from the committed `_freeze/` cache
(`execute: freeze: true` in `_quarto.yml`), so **no Python environment or upstream
data pipeline is required** to build the slides. The only external dependency at
view time is the Font Awesome CDN (for a few inline icons).

> Always use the project form (`make render` / `quarto render`), **not**
> `quarto render index.qmd` — targeting the file directly bypasses the freeze cache
> and would try to start a Jupyter kernel.

## Sync from the workshop repo

This deck is a curated copy of the slides in the main workshop repo
(`tvb-ontology-optim-workshop`). The intended workflow is **one-way**: do the
authoring in the workshop repo, then pull the result here and commit/push *this*
repo.

```bash
# 1. edit slides + regenerate figures in ../tvb-ontology-optim-workshop
# 2. in this repo:
make sync                                   # assumes the workshop repo is ../tvb-ontology-optim-workshop
make sync SRC=/path/to/tvb-ontology-optim-workshop
make render                                 # rebuild index.html
# 3. git commit / push this repo
```

> Sync is **one-way (workshop → lecture)**. Don't hand-edit the synced slide files
> here — the next `make sync` will overwrite them. Only this repo's own files
> (`_quarto.yml`, `_slides-home-btn.html`, `README.md`, `Makefile`, `sync.sh`,
> `watch.sh`, `.gitignore`) are preserved.

`sync.sh` copies the active chapters, re-derives every referenced asset
(`img/ data/ js/`), and refreshes the `clean-revealjs` extension and the `_freeze/`
cache. It is **non-destructive to this repo's own files** (`_quarto.yml`,
`_slides-home-btn.html`, `README.md`, `Makefile`, `.gitignore`).

> Code-generated plots (e.g. the *Mathematical framework* simulation) live in the
> `_freeze/` cache. For a fix to appear here, the **workshop repo must re-render that
> cell first**; then `make sync` carries the updated figure across. (No Python or
> `tvbo` install is needed in *this* repo.)

### Auto-sync while you work

One command runs the syncer **and** the preview together:

```bash
make dev        # watch the workshop repo + live preview; Ctrl-C stops both
```

Editing in the workshop repo then flows through automatically: **watch → sync →
preview reload**. (Prefer two terminals? Run `make watch` and `make preview`
separately — `make preview` on its own only watches *this* repo's files.)

It polls every 2 s; `brew install fswatch` upgrades it to instant, event-based
watching. Code-generated figures still need the workshop repo to re-render that
cell first — see the note above.

## Layout

| Path | What it is |
|------|------------|
| `index.qmd` | Entry point; sets the `clean-revealjs` format and includes the chapters |
| `slides/` | Chapter partials: `_01-intro`, `_02-fair-model`, `_04-clinical`, `_05-bifurcation`, `_07-stimulation` |
| `authors_gallery.qmd` | Acknowledgements gallery (remote portrait images) |
| `img/` | Figures, videos and QR codes used on the slides |
| `data/` | Brain-mesh + connectome JSON for the animated backdrops |
| `js/home-visual.js` | Canvas web component (`<brain-network-visual>`) |
| `brain-network-background.html` · `brain-build.html` · `brain-recap.html` | Backdrop iframes (title / build-up / recap) |
| `slides.css` · `_slides-home-btn.html` | Deck styling and the Font Awesome include |
| `_extensions/grantmcdermott/clean` | The `clean-revealjs` theme |
| `_freeze/` | Cached code-cell outputs (figures) so the deck builds without re-running code |

## Notes

- Only the chapters actually included by `index.qmd` were copied. The original
  workshop's setup (`_03`) and parameter-exploration (`_06`) chapters are commented
  out there and are **not** part of this deck.
- To regenerate figures from source, you'd need the original workshop repo's
  `code/` scripts and `_dev/tvb-o-clinical.ttl`, plus a Python environment; then set
  `execute: freeze: auto`.
