import firebaseAnalytics from '@react-native-firebase/analytics';
import { log } from './logger';
import type { AnalyticsService } from '../interfaces/analyticsService';
import type { AnalyticsConfig } from '../interfaces/config';

export function createAnalytics(
  config: AnalyticsConfig = {},
): AnalyticsService {
  return {
    async trackEvent(name, params) {
      if (config.disabled) return;
      try {
        await firebaseAnalytics().logEvent(name, params);
      } catch (err) {
        await log('WARN', `Failed to log analytics event: ${String(err)}`);
      }
    },
  };
}

export const analytics = createAnalytics();
export const trackEvent = analytics.trackEvent;
