import * as Notifications from 'expo-notifications';
import type {
  NotificationsService,
  PhaseColor,
  PhaseEmitter,
} from '../interfaces/notifications';

export async function notifyDriver(phase: PhaseColor): Promise<void> {
  await Notifications.scheduleNotificationAsync({
    content: {
      title: 'Phase change',
      body: `Phase is now ${phase}`,
    },
    trigger: null,
  });
}

export function subscribeToPhaseChanges(emitter: PhaseEmitter): void {
  emitter.on('phase', (phase: PhaseColor) => {
    void notifyDriver(phase);
  });
}

export const notifications: NotificationsService = {
  subscribeToPhaseChanges,
  notifyDriver,
};
