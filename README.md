# ~/n6ufal

This is the source code for my personal site and digital garden at [alifnaufal.me](https://alifnaufal.me/).

It's built with [Hugo](https://gohugo.io/) using a highly customized version of the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme, styled with the [Nord color palette](https://www.nordtheme.com/).

## 🌟 Features

- **Digital Garden**: A personal dumping ground for notes, stories, thoughts, and technical exploration.
- **Live Last.fm Widget**: Custom-coded, real-time widget pulling recently played music with actual album art from the Last.fm API.
- **Nord Styling**: Custom CSS tailored around Nord dark colors, refined typography (IBM Plex Mono & Sans), clean syntax highlighting, and smooth hover transitions.
- **Performance & SEO**: Native dark mode, lightning-fast loads, tags, archive pagination, sitemap, and RSS feed.

## 🛠️ Tech Stack & Structure

- **SSG**: [Hugo](https://gohugo.io/) (Extended Edition)
- **Theme**: [PaperMod](https://github.com/adityatelange/hugo-PaperMod) (extended using layout overrides)
- **Styling**: CSS under `assets/css/extended/custom.css`
- **Asset Automation**: Custom Python scripts for asset generation

## 🚀 Running Locally

1. **Clone the repository recursively** (to pull the PaperMod theme submodule):

   ```bash
   git clone --recursive https://github.com/n6ufal/n6ufal.github.io.git
   cd n6ufal.github.io
   ```

2. **Start the Hugo development server**:

   ```bash
   hugo server -D
   ```

   _(The `-D` flag tells Hugo to include draft posts in local builds)._

3. Open `http://localhost:1313` in your browser.

## 🐍 Automation Scripts

### Favicon Generator (`scripts/generate_favicons.py`)

Includes a custom Python script that downloads `IBMPlexSans-Bold`, extracts the vector geometry of the letter **A**, scales/positions it, and automatically generates SVG, ICO, and various PNG favicons in Nord dark and green colors.

To run it:

```bash
pip install Pillow fontTools
python scripts/generate_favicons.py
```

## 📜 Credits

- Favicons by [Javier Danglada](https://www.flaticon.com/authors/javier-danglada) (original inspiration)
- Base theme template by Aditya Telange ([PaperMod](https://github.com/adityatelange/hugo-PaperMod))
- Nord color scheme by [Arctic Ice Studio](https://github.com/arcticicestudio)
