export type TrafficSignal = 'red' | 'yellow' | 'green';

export interface SignalEmitter {
  on(event: 'signal', listener: (signal: TrafficSignal) => void): void;
}

export interface NotificationsService {
  subscribeToSignalChanges(emitter: SignalEmitter): void;
  notifyDriver(signal: TrafficSignal): Promise<void>;
}
