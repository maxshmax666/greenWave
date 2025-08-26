export type Direction = 'MAIN' | 'SECONDARY' | 'PEDESTRIAN';

export type Light = {
  id: string;
  name: string;
  lat: number;
  lon: number;
  direction: Direction;
};

export type LightCycle = {
  id: string;
  light_id: string;
  cycle_seconds: number;
  t0_iso: string; // ISO datetime
  main_green: [number, number];
  secondary_green: [number, number];
  ped_green: [number, number];
};

export type RouteLeg = {
  distance_m: number;
  duration_s: number;
  coords: [number, number][];
};
