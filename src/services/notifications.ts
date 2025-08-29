import * as Notifications from 'expo-notifications';
import type {
  NotificationsService,
  PhaseColor,
  PhaseEmitter,
} from '../interfaces/notifications';
import { getUpcomingPhase } from './lights';

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

export async function notifyGreenPhase(lightId: string): Promise<void> {
  const upcoming = await getUpcomingPhase(lightId);
  if (!upcoming) return;
  await Notifications.scheduleNotificationAsync({
    content: {
      title: 'Upcoming green',
      body: `${upcoming.direction} in ${Math.round(upcoming.startIn)}s`,
    },
    trigger:
      upcoming.startIn > 0 ? { seconds: Math.ceil(upcoming.startIn) } : null,
  });
}

export const notifications: NotificationsService = {
  subscribeToPhaseChanges,
  notifyDriver,
  notifyGreenPhase,
};
