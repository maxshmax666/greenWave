import * as Analytics from 'expo-firebase-analytics';
import { log } from './logger';
import type { Analytics as AnalyticsInterface } from '../src/interfaces/analytics';

export const analytics: AnalyticsInterface = {
  async trackEvent(name, params) {
    try {
      await Analytics.logEvent(name, params);
    } catch (err) {
      await log('WARN', `Failed to log analytics event: ${String(err)}`);
    }
  },
};

export const trackEvent = analytics.trackEvent;
