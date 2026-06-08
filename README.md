# ~/n6ufal

**What** — Personal digital garden at [alifnaufal.me](https://alifnaufal.me/).

**Why** — A space for personal essays, technical projects, and notes that grow over time.

**How** — Built with [Hugo Extended](https://gohugo.io/) + a **[heavily customized PaperMod](https://github.com/adityatelange/hugo-PaperMod)** theme + a **custom Nord palette** (cherry-picked, not strict). Vanilla JS only — zero npm/Node.js. CI/CD via GitHub Actions to GitHub Pages.

## Quick start

```bash
git clone --recursive https://github.com/n6ufal/n6ufal.github.io.git
cd n6ufal.github.io
hugo server -D
```

The `-D` flag includes drafts. Open `http://localhost:1313`.

## Commands

| To…                      | Run                                  |
|--------------------------|--------------------------------------|
| Dev server with drafts   | `hugo server -D`                     |
| Production build         | `hugo --minify`                      |
| Regenerate syntax CSS    | `hugo gen chromastyles --style=nord` |

## Submodule

If cloned without `--recursive`:

```bash
git submodule update --init --recursive
```

## Credits

- [PaperMod](https://github.com/adityatelange/hugo-PaperMod) by Aditya Telange
- [Nord](https://www.nordtheme.com/) by Arctic Ice Studio
