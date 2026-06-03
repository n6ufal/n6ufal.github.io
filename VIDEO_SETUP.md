# Video Background Setup

## Overview

The homepage has a looping video background that starts muted and paused. A "Click Anywhere" entry overlay must be dismissed before the video plays with sound. This is required by browser autoplay policies — video with audio cannot start without a user gesture.

## Files

- `layouts/partials/home-video-bg.html` — Video element and player logic
- `layouts/partials/entry-overlay.html` — Click-to-play overlay
- `layouts/partials/video-mute-button.html` — Mute toggle button (M key)
- `static/videos/bg-video.mp4` — Video file
- CSS in `assets/css/extended/custom.css` — Video styling, scanline overlay, mute button

## How to Add a Video

### Prepare the Video

Single MP4 file (H.264 codec):

```bash
ffmpeg -i input-video.mov -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k bg-video.mp4
```

Target ~4-5 MB for 1:30 min at 2-3 Mbps.

### Place the File

```
static/
└── videos/
    └── bg-video.mp4
```

## UX Flow

1. Page loads — video is **muted** and **paused**
2. Entry overlay appears with "Click Anywhere" scramble animation
3. User clicks overlay — scramble resolves, ripple + coordinate animation plays
4. Overlay fades out, `window.playVideoWithSound()` unmutes and plays the video
5. **M key** toggles mute on/off (speaker/muted icons in header)
6. Switching tabs pauses the video and mutes audio; returning resumes if it was playing

## Customization

### Adjust Overlay Darkness

Edit `assets/css/extended/custom.css`:

```css
.home-video-bg__overlay {
    background-color: rgba(0, 0, 0, 0.5); /* increase to darken, decrease to lighten */
}
```

### Change Scanline Effect

The scanlines and dot pattern use `repeating-linear-gradient` with `mix-blend-mode: multiply` in the same CSS block. Tweak the color stops or remove the `background-image` entirely for a clean overlay.

### Remove Entry Overlay

Delete `layouts/partials/entry-overlay.html` and remove its inclusion from `layouts/baseof.html`. Change `home-video-bg.html` to autoplay muted:

```javascript
video.muted = true;
video.play();
```

## Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- iOS Safari 14+
- Android Chrome 90+

Autoplay with audio requires a user gesture on all modern browsers. The entry overlay satisfies this requirement.

## Performance Notes

- Video loads with the page (not lazy-loaded)
- `preload="metadata"` avoids downloading the full video until playback starts
- The grain/scanline overlay is pure CSS — no JavaScript impact
- Fixed positioning means the video doesn't scroll
- `requestAnimationFrame` in the entry overlay auto-pauses when the tab is hidden

## Troubleshooting

### Video not playing on mobile
- Ensure HTTPS (required for autoplay on iOS)
- Tap the entry overlay to trigger playback

### Audio not playing after clicking
- Verify the MP4 file contains an audio track
- Check browser console for playback errors
- Some browsers may still block unmuted autoplay; the script falls back to muted play

### Overlay too strong/too light
- Adjust the `rgba(0, 0, 0, 0.5)` value in `.home-video-bg__overlay` CSS
- Higher = darker, lower = lighter

## Testing Locally

```bash
hugo server -D
```

Visit `http://localhost:1313/` and verify:
- [ ] Video appears on homepage (paused, muted)
- [ ] Entry overlay shows with scramble animation
- [ ] Clicking overlay plays video with audio
- [ ] M key toggles mute on/off
- [ ] Text is readable over video
- [ ] Video doesn't appear on Posts/Archive/About pages
- [ ] Scanline overlay is subtle
