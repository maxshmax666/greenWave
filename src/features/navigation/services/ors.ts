import { network } from '../../../services/network';

export interface LatLng {
  latitude: number;
  longitude: number;
}

export interface RouteStep {
  instruction: string;
  distance: number;
  duration: number;
  name: string;
  speed: number;
}

export interface RouteResult {
  geometry: LatLng[];
  distance: number;
  duration: number;
  steps: RouteStep[];
}

export async function getRoute(
  start: LatLng,
  end: LatLng,
): Promise<RouteResult> {
  const apiKey = process.env.EXPO_PUBLIC_ORS_API_KEY;
  if (!apiKey) {
    throw new Error('EXPO_PUBLIC_ORS_API_KEY is required');
  }

  const url = `https://api.openrouteservice.org/v2/directions/driving-car?start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}`;

  let res: Response;
  try {
    res = await network.fetchWithTimeout(url, {
      headers: { Authorization: apiKey },
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    throw new Error(`Unable to fetch route. ${message}`);
  }

  const json = await res.json();
  const feature = json.features?.[0];
  if (!feature) {
    throw new Error('Route not found');
  }
  const coords: LatLng[] = feature.geometry.coordinates.map(
    ([lon, lat]: [number, number]) => ({
      latitude: lat,
      longitude: lon,
    }),
  );
  interface ORSStep {
    instruction: string;
    distance: number;
    duration: number;
    name: string;
    speed?: number;
    speed_limit?: number;
  }
  const steps: RouteStep[] =
    feature.properties?.segments?.[0]?.steps?.map((s: ORSStep) => ({
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
