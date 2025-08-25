export async function getRoute(start, end) {
  // Placeholder for OpenRouteService API
  return {
    geometry: [
      { latitude: start.latitude, longitude: start.longitude },
      { latitude: end.latitude, longitude: end.longitude }
    ],
    distance: 1000,
    duration: 600,
    maneuvers: [
      { instruction: 'Head north', distance: 500 },
      { instruction: 'Turn right', distance: 500 }
    ]
  };
}
