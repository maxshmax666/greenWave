import { EventEmitter } from 'events';
import * as Notifications from 'expo-notifications';
import type { PhaseEmitter } from '../../interfaces/notifications';

jest.mock('expo-notifications');
jest.mock('../traffic/lights', () => ({ getUpcomingPhase: jest.fn() }));
jest.mock('../../stores/leadTime', () => ({
  leadTimeStore: { get: jest.fn().mockResolvedValue(0) },
}));

import {
  notifyDriver,
  notifyGreenPhase,
  subscribeToPhaseChanges,
} from '../notifications';
import { getUpcomingPhase } from '../traffic/lights';
import { leadTimeStore } from '../../stores/leadTime';

describe('notifications service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('notifies driver directly', async () => {
    await notifyDriver('green');
    expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledWith({
      content: {
        title: 'Phase change',
        body: 'Phase is now green',
      },
      trigger: null,
    });
  });

  it('subscribes to phase changes', () => {
    const emitter = new EventEmitter();
    const unsubscribe = subscribeToPhaseChanges(
      emitter as unknown as PhaseEmitter,
    );
    emitter.emit('phase', 'red');
    expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledTimes(1);
    (Notifications.scheduleNotificationAsync as jest.Mock).mockClear();
    unsubscribe();
    emitter.emit('phase', 'green');
    expect(Notifications.scheduleNotificationAsync).not.toHaveBeenCalled();
  });

  it('schedules notification when startIn > 0', async () => {
    (getUpcomingPhase as jest.Mock).mockResolvedValueOnce({
      direction: 'MAIN',
      startIn: 5,
    });
    await notifyGreenPhase('1');
    expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledWith({
      content: { title: 'Upcoming green', body: 'MAIN in 5s' },
      trigger: { seconds: 5 },
    });
  });

  it('honors lead time', async () => {
    (getUpcomingPhase as jest.Mock).mockResolvedValueOnce({
      direction: 'SECONDARY',
      startIn: 10,
    });
    await notifyGreenPhase('2', 4);
    expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledWith({
      content: { title: 'Upcoming green', body: 'SECONDARY in 6s' },
      trigger: { seconds: 6 },
    });
  });

  it('uses null trigger when lead time exceeds start', async () => {
    (getUpcomingPhase as jest.Mock).mockResolvedValueOnce({
      direction: 'MAIN',
      startIn: 3,
    });
    await notifyGreenPhase('id', 5);
    expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledWith(
      expect.objectContaining({ trigger: null }),
    );
  });

  it('does not schedule when no upcoming phase', async () => {
    (getUpcomingPhase as jest.Mock).mockResolvedValueOnce(null);
    await notifyGreenPhase('1');
    expect(Notifications.scheduleNotificationAsync).not.toHaveBeenCalled();
  });

  it('uses stored lead time by default', async () => {
    (leadTimeStore.get as jest.Mock).mockResolvedValueOnce(3);
    (getUpcomingPhase as jest.Mock).mockResolvedValueOnce({
      direction: 'MAIN',
      startIn: 8,
    });
    await notifyGreenPhase('3');
    expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledWith({
      content: { title: 'Upcoming green', body: 'MAIN in 5s' },
      trigger: { seconds: 5 },
    });
  });
});
