# Last.fm Widget Setup

## What Changed

The Last.fm widget has been **fixed** to address critical issues:

### Issues Fixed ✅
1. **CORS Problem** - Now uses a serverless backend to fetch Last.fm data
2. **Security** - API key is no longer exposed in frontend code
3. **HTML Escaping** - Improved to handle all special characters including quotes

### How It Works

- Frontend shortcode (`layouts/shortcodes/lastfm.html`) calls a **serverless function**
- Function (`netlify/functions/lastfm.js`) fetches from Last.fm API **server-side** with secure credentials
- API key stored in environment variables, not in code

## Setup Instructions

### For Local Development

1. Install Netlify CLI (optional, for testing functions locally):
   ```bash
   npm install -g netlify-cli
   ```

2. Set environment variables in `.env.local` (already created):
   ```
   LASTFM_API_KEY=0e7245c9a19b6563e2a301c91f053c54
   LASTFM_USER=alifnaufal
   ```

3. Run Hugo normally:
   ```bash
   hugo server
   ```
   
   **Note**: Local Last.fm widget won't work without running `netlify dev`. To test with functions locally:
   ```bash
   netlify dev
   ```

### For Netlify Deployment

1. Connect your repository to Netlify
2. Set environment variables in **Netlify Dashboard** → Site settings → Build & deploy → Environment:
   - `LASTFM_API_KEY`: Your Last.fm API key
   - `LASTFM_USER`: Your Last.fm username

3. Deploy! The widget will work automatically.

## Files Added/Modified

- ✨ **netlify/functions/lastfm.js** - Serverless function for Last.fm API
- ✨ **netlify.toml** - Netlify configuration
- ✨ **.env.local** - Local environment variables
- ✨ **.gitignore** - Prevents committing secrets
- 📝 **layouts/shortcodes/lastfm.html** - Updated to use serverless function

## Security Notes

- ✅ API key never exposed in browser
- ✅ 30-second cache on Netlify function
- ✅ CORS issues resolved
- ⚠️ Keep `.env.local` in `.gitignore` (already added)
