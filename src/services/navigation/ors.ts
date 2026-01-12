import { network } from '../network';

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

type ORSFeature = {
  geometry: {
    coordinates: [number, number][];
  };
  properties: {
    summary: {
      distance: number;
      duration: number;
    };
    segments?: Array<{
      steps?: unknown[];
    }>;
  };
};

const isNumber = (value: unknown): value is number =>
  typeof value === 'number' && Number.isFinite(value);

const hasValidCoordinates = (
  coords: unknown,
): coords is [number, number][] =>
  Array.isArray(coords) &&
  coords.every(
    (pair) =>
      Array.isArray(pair) &&
      pair.length >= 2 &&
      isNumber(pair[0]) &&
      isNumber(pair[1]),
  );

const hasValidSummary = (
  summary: unknown,
): summary is ORSFeature['properties']['summary'] =>
  !!summary &&
  typeof summary === 'object' &&
  isNumber((summary as { distance?: unknown }).distance) &&
  isNumber((summary as { duration?: unknown }).duration);

const isValidOrsResponse = (data: unknown): data is { features: ORSFeature[] } => {
  if (!data || typeof data !== 'object') {
    return false;
  }
  const features = (data as { features?: unknown }).features;
  if (!Array.isArray(features) || features.length === 0) {
    return false;
  }
  const feature = features[0] as ORSFeature | undefined;
  if (!feature || typeof feature !== 'object') {
    return false;
  }
  const geometry = feature.geometry;
  const properties = feature.properties;
  if (!geometry || !properties) {
    return false;
  }
  return (
    hasValidCoordinates(geometry.coordinates) &&
    hasValidSummary(properties.summary)
  );
};

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
  if (!isValidOrsResponse(json)) {
    throw new Error('Invalid ORS response shape');
  }
  const feature = json.features[0];
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
