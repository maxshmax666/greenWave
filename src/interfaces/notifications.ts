export type PhaseColor = 'red' | 'yellow' | 'green';

export interface PhaseEmitter {
  on(event: 'phase', listener: (phase: PhaseColor) => void): void;
}

export interface NotificationsService {
  subscribeToPhaseChanges(emitter: PhaseEmitter): void;
  notifyDriver(phase: PhaseColor): Promise<void>;
}
