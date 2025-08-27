import * as Analytics from 'expo-firebase-analytics';
import { log } from './logger';

export async function trackEvent(
  name: string,
  params?: Record<string, unknown>,
): Promise<void> {
  try {
    await Analytics.logEvent(name, params);
  } catch (err) {
    await log('WARN', `Failed to log analytics event: ${String(err)}`);
  }
}
