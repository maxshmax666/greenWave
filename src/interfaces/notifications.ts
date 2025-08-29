export type PhaseColor = 'red' | 'yellow' | 'green';

export interface PhaseEmitter {
  on(event: 'phase', listener: (phase: PhaseColor) => void): void;
  off(event: 'phase', listener: (phase: PhaseColor) => void): void;
}

export interface NotificationsService {
  subscribeToPhaseChanges(emitter: PhaseEmitter): () => void;
  notifyDriver(phase: PhaseColor): Promise<void>;
  notifyGreenPhase(lightId: string, leadTimeSec?: number): Promise<void>;
}
