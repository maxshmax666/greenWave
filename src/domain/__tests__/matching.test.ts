import { projectLightsToRoute } from '../matching';
import { Light, RouteLeg } from '../types';

describe('projectLightsToRoute', () => {
  const route: RouteLeg[] = [
    {
      distance_m: 1000,
      duration_s: 60,
      coords: [
        [0, 0],
        [0, 0.01], // ~1.1km east
      ],
    },
  ];

  const lights: Light[] = [
    { id: '1', name: 'A', lat: 0, lon: 0.005, direction: 'MAIN' }, // mid route
    { id: '2', name: 'B', lat: 0, lon: 0.009, direction: 'MAIN' }, // near end
    { id: '3', name: 'C', lat: 0.5, lon: 0.5, direction: 'MAIN' }, // far away
  ];

  it('filters and sorts lights along route', () => {
    const res = projectLightsToRoute(lights, route);
    expect(res.map(r => r.light.id)).toEqual(['1', '2']);
    expect(res[0].order_m).toBeLessThan(res[1].order_m);
    expect(res[0].dist_m).toBeLessThan(70);
  });
});
