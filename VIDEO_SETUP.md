# Video Background Setup

## Overview
The homepage now has support for a looping video background with audio enabled. The video extends behind the header and footer, with a light TV grain overlay for readability.

## Files Created
- `layouts/partials/home-video-bg.html` - Video background partial
- `static/videos/` - Directory for video files
- CSS in `assets/css/extended/custom.css` - Video styling and grain overlay

## How to Add Your Video

### Step 1: Prepare Your Video Files
You need to provide video in two formats for maximum browser compatibility:

1. **MP4 Format** (H.264 codec)
   - File: `bg-video.mp4`
   - Size: Target ~4-5 MB for 1:30 min
   - Codec: H.264 video, AAC audio
   - Bitrate: ~2-3 Mbps (good quality/size tradeoff)

2. **WebM Format** (VP9 codec, optional but recommended)
   - File: `bg-video.webm`
   - Size: Target ~2-3 MB for 1:30 min (more efficient)
   - Codec: VP9 video, Vorbis audio
   - Bitrate: ~1.5-2 Mbps

### Step 2: Encode Your Video

**For MP4:**
```bash
ffmpeg -i input-video.mov -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k bg-video.mp4
```

**For WebM (optional, but smaller file):**
```bash
ffmpeg -i input-video.mov -c:v libvpx-vp9 -crf 30 -c:a libopus -b:a 96k bg-video.webm
```

### Step 3: Place Video Files
Copy your encoded video files to: `/static/videos/`

Structure should look like:
```
static/
└── videos/
    ├── bg-video.mp4    (required)
    └── bg-video.webm   (optional, recommended for modern browsers)
```

## Features

✅ **Autoplay on Page Load** - Video starts playing automatically
✅ **Audio On** - Audio is enabled by default on both desktop and mobile
✅ **Looping** - Video loops seamlessly when it ends
✅ **Full Viewport Coverage** - Extends behind header and footer
✅ **Light TV Grain Overlay** - Subtle noise effect for text readability
✅ **Responsive** - Works on desktop, tablet, and mobile
✅ **Homepage Only** - Only appears on the homepage; other pages use static backgrounds

## Customization

### Adjust Overlay Opacity
Edit `assets/css/extended/custom.css`, line with `.home-video-bg__overlay`:
- Current: `opacity: 0.12;` (light grain)
- Darker: increase to `0.15` or `0.2`
- Lighter: decrease to `0.08` or `0.1`

### Disable Audio
If you want to mute audio by default, edit `layouts/partials/home-video-bg.html`:
Change `muted="false"` to `muted="true"`

### Change Mix Blend Mode
For different visual effects with the grain overlay, try:
- `mix-blend-mode: overlay;` (current, darkens)
- `mix-blend-mode: multiply;` (stronger darkening)
- `mix-blend-mode: screen;` (lightening effect)
- `mix-blend-mode: normal;` (no blending)

## Browser Support

- ✅ Chrome/Edge 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ iOS Safari 14+
- ✅ Android Chrome 90+

Note: The `muted="false"` attribute requires user interaction on some mobile browsers to play audio due to autoplay policies. However, this setup uses `autoplay` and `muted="false"` which should work on modern browsers.

## Performance Notes

- Video loads with the page (not lazy-loaded on homepage)
- Use MP4 as primary format for wider compatibility
- WebM format is optional but recommended (smaller file size)
- The grain overlay is pure CSS/SVG (no JavaScript performance impact)
- Fixed positioning means the video doesn't scroll (efficient)

## Troubleshooting

### Video not playing on mobile
- Ensure you're using HTTPS (required for autoplay on iOS)
- Check that both MP4 and WebM formats are in `/static/videos/`
- Try muting first: change `muted="false"` to `muted="true"` temporarily to test

### Audio not playing
- Verify the video file contains audio track
- Check browser console for CORS or playback errors
- On iOS, user gesture may be required to unmute

### Grain overlay too strong/too light
- Adjust `opacity` value in `.home-video-bg__overlay` CSS (current: 0.12)

## Testing Locally

Build and serve your Hugo site:
```bash
hugo server
```

Visit `http://localhost:1313/` and verify:
- [ ] Video appears on homepage
- [ ] Video autoplays and loops
- [ ] Audio plays
- [ ] Text is readable over video
- [ ] Video doesn't appear on Posts/Archive/About pages
- [ ] Grain overlay is subtle (not distracting)
