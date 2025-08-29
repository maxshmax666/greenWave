import { EventEmitter } from 'events';
import * as Notifications from 'expo-notifications';
import type { PhaseEmitter } from '../../interfaces/notifications';

jest.mock('expo-notifications');
jest.mock('../lights', () => ({ getUpcomingPhase: jest.fn() }));

import {
  notifyDriver,
  notifyGreenPhase,
  subscribeToPhaseChanges,
} from '../notifications';
import { getUpcomingPhase } from '../lights';

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
    subscribeToPhaseChanges(emitter as unknown as PhaseEmitter);
    emitter.emit('phase', 'red');
    expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledTimes(1);
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

  it('does not schedule when no upcoming phase', async () => {
    (getUpcomingPhase as jest.Mock).mockResolvedValueOnce(null);
    await notifyGreenPhase('1');
    expect(Notifications.scheduleNotificationAsync).not.toHaveBeenCalled();
  });
});
