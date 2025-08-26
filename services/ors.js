async function getRoute(start, end) {
  const apiKey = process.env.EXPO_PUBLIC_ORS_API_KEY;
  if (!apiKey) {
    throw new Error('EXPO_PUBLIC_ORS_API_KEY is required');
  }

  const url = `https://api.openrouteservice.org/v2/directions/driving-car?start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}`;

  let res;
  try {
    res = await fetch(url, { headers: { Authorization: apiKey } });
  } catch (err) {
    throw new Error(`Failed to fetch route: ${err instanceof Error ? err.message : err}`);
  }

  if (!res.ok) {
    const message = await res.text();
    throw new Error(`OpenRouteService error ${res.status}: ${message}`);
  }

  const json = await res.json();
  const feature = json.features[0];
  const coords = feature.geometry.coordinates.map(([lon, lat]) => ({
    latitude: lat,
    longitude: lon,
  }));
  return {
    geometry: coords,
    distance: feature.properties.summary.distance,
    duration: feature.properties.summary.duration,
  };
}

module.exports = { getRoute };
