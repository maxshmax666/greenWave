import * as Analytics from 'expo-firebase-analytics';

export async function trackEvent(name: string, params?: Record<string, any>): Promise<void> {
  try {
    await Analytics.logEvent(name, params);
  } catch (err) {
    console.warn('Failed to log analytics event', err);
  }
}
