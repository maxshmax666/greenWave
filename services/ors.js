const { fetchWithTimeout } = require('./network');

async function getRoute(start, end) {
  const apiKey = process.env.EXPO_PUBLIC_ORS_API_KEY;
  if (!apiKey) {
    throw new Error('EXPO_PUBLIC_ORS_API_KEY is required');
  }

  const url = `https://api.openrouteservice.org/v2/directions/driving-car?start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}`;

  let res;
  try {
    res = await fetchWithTimeout(url, {
      headers: { Authorization: apiKey },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    throw new Error(`Unable to fetch route. ${message}`);
  }

  const json = await res.json();
  const feature = json.features[0];
  const coords = feature.geometry.coordinates.map(([lon, lat]) => ({
    latitude: lat,
    longitude: lon,
  }));
  const steps =
    feature.properties?.segments?.[0]?.steps?.map(s => ({
      instruction: s.instruction,
      distance: s.distance,
      duration: s.duration,
      name: s.name,
      speed: s.speed || s.speed_limit || 0,
    })) || [];
  return {
    geometry: coords,
    distance: feature.properties.summary.distance,
    duration: feature.properties.summary.duration,
    steps,
  };
}

module.exports = { getRoute };
