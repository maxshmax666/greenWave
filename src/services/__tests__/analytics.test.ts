import { createAnalytics } from '../analytics';
import { logEvent } from '@react-native-firebase/analytics';

jest.mock('@react-native-firebase/analytics');

describe('analytics service', () => {
  beforeEach(() => jest.clearAllMocks());

  it('logs events via firebase', async () => {
    const analytics = createAnalytics();
    await analytics.trackEvent('foo', { bar: 'baz' });
    expect(logEvent).toHaveBeenCalledWith('foo', { bar: 'baz' });
  });

  it('skips logging when disabled', async () => {
    const analytics = createAnalytics({ disabled: true });
    await analytics.trackEvent('foo', { bar: 'baz' });
    expect(logEvent).not.toHaveBeenCalled();
  });
});
