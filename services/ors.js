export async function getRoute(start, end) {
  const apiKey = process.env.EXPO_PUBLIC_ORS_API_KEY;
  const url = `https://api.openrouteservice.org/v2/directions/driving-car?start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}`;
  const res = await fetch(url, { headers: { Authorization: apiKey } });
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
