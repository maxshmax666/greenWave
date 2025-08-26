import { Light, RouteLeg } from './types';

function toXY([lat, lon]: [number, number]) {
  const R = 111139; // meters per degree
  const x = lon * R * Math.cos((lat * Math.PI) / 180);
  const y = lat * R;
  return { x, y };
}

function projectPointToSegment(
  p: [number, number],
  a: [number, number],
  b: [number, number]
) {
  const P = toXY(p);
  const A = toXY(a);
  const B = toXY(b);
  const ABx = B.x - A.x;
  const ABy = B.y - A.y;
  const ab2 = ABx * ABx + ABy * ABy;
  let t = 0;
  if (ab2 > 0) {
    t = ((P.x - A.x) * ABx + (P.y - A.y) * ABy) / ab2;
    t = Math.max(0, Math.min(1, t));
  }
  const projx = A.x + t * ABx;
  const projy = A.y + t * ABy;
  const dx = P.x - projx;
  const dy = P.y - projy;
  const dist = Math.sqrt(dx * dx + dy * dy);
  return { dist, t };
}

export function projectLightsToRoute(
  lights: Light[],
  route: RouteLeg[]
): { light: Light; dist_m: number; order_m: number }[] {
  const coords: [number, number][] = [];
  for (const leg of route) coords.push(...leg.coords);
  const segments: {
    a: [number, number];
    b: [number, number];
    len: number;
  }[] = [];
  for (let i = 0; i < coords.length - 1; i++) {
    const a = coords[i];
    const b = coords[i + 1];
    const A = toXY(a);
    const B = toXY(b);
    const len = Math.sqrt((B.x - A.x) ** 2 + (B.y - A.y) ** 2);
    segments.push({ a, b, len });
  }

  const result: { light: Light; dist_m: number; order_m: number }[] = [];
  for (const light of lights) {
    let bestDist = Infinity;
    let bestOrder = 0;
    let traveled = 0;
    for (const seg of segments) {
      const { dist, t } = projectPointToSegment(
        [light.lat, light.lon],
        seg.a,
        seg.b
      );
      if (dist < bestDist) {
        bestDist = dist;
        bestOrder = traveled + seg.len * t;
      }
      traveled += seg.len;
    }
    if (bestDist <= 70) {
      result.push({ light, dist_m: bestDist, order_m: bestOrder });
    }
  }

  result.sort((a, b) => a.order_m - b.order_m);
  return result;
}
