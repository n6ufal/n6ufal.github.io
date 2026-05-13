// Netlify Function to fetch Last.fm data server-side
// This keeps the API key secure and avoids CORS issues

exports.handler = async (event, context) => {
  // Only allow GET requests
  if (event.httpMethod !== "GET") {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: "Method not allowed" }),
    };
  }

  const apiKey = process.env.LASTFM_API_KEY;
  const user = process.env.LASTFM_USER || "alifnaufal";

  if (!apiKey) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "API key not configured" }),
    };
  }

  const url = `https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=${encodeURIComponent(
    user
  )}&api_key=${apiKey}&format=json&limit=5`;

  try {
    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`Last.fm API returned ${response.status}`);
    }

    const data = await response.json();

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Cache-Control": "public, max-age=30", // Cache for 30 seconds
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    console.error("Last.fm fetch error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};
