import { Direction, LightCycle } from './types';

export function getGreenWindow(c: LightCycle, dir: Direction): [number, number] {
  if (dir === 'MAIN') return [c.main_green[0], c.main_green[1]];
  if (dir === 'SECONDARY') return [c.secondary_green[0], c.secondary_green[1]];
  return [c.ped_green[0], c.ped_green[1]];
}

export function mapColorForRuntime(
  cycle: LightCycle | null,
  dir: Direction,
  nowSec: number
) {
  if (!cycle) return 'gray';
  const cycleLen = cycle.cycle_seconds;
  const t0 = Date.parse(cycle.t0_iso) / 1000;
  const phase = ((nowSec - t0) % cycleLen + cycleLen) % cycleLen;
  const [gs, ge] = getGreenWindow(cycle, dir);
  const isGreen = phase >= gs && phase <= ge;
  if (dir === 'PEDESTRIAN') return isGreen ? 'blue' : 'gray';
  if (dir === 'SECONDARY') return isGreen ? 'green' : 'gray';
  if (dir === 'MAIN') return isGreen ? 'red' : 'gray';
  return 'gray';
}
