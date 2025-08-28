import firebaseAnalytics from '@react-native-firebase/analytics';
import { log } from './logger';
import type { AnalyticsService } from '../interfaces/analyticsService';

export const analytics: AnalyticsService = {
  async trackEvent(name, params) {
    try {
      await firebaseAnalytics().logEvent(name, params);
    } catch (err) {
      await log('WARN', `Failed to log analytics event: ${String(err)}`);
    }
  },
};

export const trackEvent = analytics.trackEvent;
