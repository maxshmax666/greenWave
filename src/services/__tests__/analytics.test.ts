import { trackEvent } from '../analytics';
import { logEvent } from '@react-native-firebase/analytics';

jest.mock('@react-native-firebase/analytics');

describe('analytics service', () => {
  it('logs events via firebase', async () => {
    await trackEvent('foo', { bar: 'baz' });
    expect(logEvent).toHaveBeenCalledWith('foo', { bar: 'baz' });
  });
});
