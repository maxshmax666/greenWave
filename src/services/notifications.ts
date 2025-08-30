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

export function subscribeToPhaseChanges(emitter: PhaseEmitter): () => void {
  const listener = (phase: PhaseColor) => {
    void notifyDriver(phase);
  };
  emitter.on('phase', listener);
  return () => {
    emitter.off('phase', listener);
  };
}

export async function notifyGreenPhase(
  lightId: string,
  leadTimeSec = 0,
): Promise<void> {
  const upcoming = await getUpcomingPhase(lightId);
  if (!upcoming) return;
  const startIn = Math.max(0, upcoming.startIn - leadTimeSec);
  const trigger = startIn > 0 ? { seconds: Math.ceil(startIn) } : null;
  await Notifications.scheduleNotificationAsync({
    content: {
      title: 'Upcoming green',
      body: `${upcoming.direction} in ${Math.round(startIn)}s`,
    },
    trigger,
  });
}

export const notifications: NotificationsService = {
  subscribeToPhaseChanges,
  notifyDriver,
  notifyGreenPhase,
};
