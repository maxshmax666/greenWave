import * as Analytics from 'expo-firebase-analytics';
import { log } from './logger';

export async function trackEvent(name: string, params?: Record<string, any>): Promise<void> {
  try {
    await Analytics.logEvent(name, params);
  } catch (err) {
    await log('WARN', `Failed to log analytics event: ${String(err)}`);
  }
}
