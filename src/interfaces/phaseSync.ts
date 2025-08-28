import type { PhaseColor } from './notifications';

export interface PhaseRecord {
  color: PhaseColor;
  startTime: number;
}

export interface PhaseSync {
  syncPhases(): Promise<void>;
}
