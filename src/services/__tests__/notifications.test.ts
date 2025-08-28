import { EventEmitter } from 'events';
import * as Notifications from 'expo-notifications';
import { notifyDriver, subscribeToPhaseChanges } from '../notifications';
import type { PhaseEmitter } from '../../interfaces/notifications';

jest.mock('expo-notifications');

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
});
