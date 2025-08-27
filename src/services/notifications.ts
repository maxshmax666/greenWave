import * as Notifications from 'expo-notifications';
import type {
  NotificationsService,
  SignalEmitter,
  TrafficSignal,
} from '../interfaces/notifications';

export async function notifyDriver(signal: TrafficSignal): Promise<void> {
  await Notifications.scheduleNotificationAsync({
    content: {
      title: 'Signal change',
      body: `Signal is now ${signal}`,
    },
    trigger: null,
  });
}

export function subscribeToSignalChanges(emitter: SignalEmitter): void {
  emitter.on('signal', (signal: TrafficSignal) => {
    void notifyDriver(signal);
  });
}

export const notifications: NotificationsService = {
  subscribeToSignalChanges,
  notifyDriver,
};
