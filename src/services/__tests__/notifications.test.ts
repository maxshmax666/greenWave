import { EventEmitter } from 'events';
import * as Notifications from 'expo-notifications';
import { notifyDriver, subscribeToSignalChanges } from '../notifications';
import type { SignalEmitter } from '../../interfaces/notifications';

jest.mock('expo-notifications');

describe('notifications service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('notifies driver directly', async () => {
    await notifyDriver('green');
    expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledWith({
      content: {
        title: 'Signal change',
        body: 'Signal is now green',
      },
      trigger: null,
    });
  });

  it('subscribes to signal changes', () => {
    const emitter = new EventEmitter();
    subscribeToSignalChanges(emitter as unknown as SignalEmitter);
    emitter.emit('signal', 'red');
    expect(Notifications.scheduleNotificationAsync).toHaveBeenCalledTimes(1);
  });
});
