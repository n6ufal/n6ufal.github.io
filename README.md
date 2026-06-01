# ~/n6ufal

Personal blog and digital garden at [alifnaufal.me](https://alifnaufal.me/), built with [Hugo](https://gohugo.io/) and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme, styled in [Nord](https://www.nordtheme.com/).

## Features

- **Video background** — looping MP4/WebM on the homepage with audio and a grain overlay
- **Entry overlay** — "Click Anywhere" scramble-resolve animation on page load
- **Live Last.fm widget** — real-time recently played tracks with album art
- **Dark mode only** — no theme toggle, Nord palette throughout
- **Vanilla JS** — zero npm/Node.js dependencies; all JavaScript is handwritten

## Quick start

```bash
git clone --recursive https://github.com/n6ufal/n6ufal.github.io.git
cd n6ufal.github.io
hugo server -D
```

The `-D` flag includes draft posts. Open `http://localhost:1313`.

### Production build

```bash
hugo --minify
```

### Regenerate syntax highlighting CSS

```bash
hugo gen chromastyles --style=nord
```

## Submodule

The PaperMod theme lives at `themes/PaperMod`. If you cloned without `--recursive`:

```bash
git submodule update --init --recursive
```

## Credits

- [PaperMod](https://github.com/adityatelange/hugo-PaperMod) by Aditya Telange
- [Nord](https://www.nordtheme.com/) by Arctic Ice Studio
