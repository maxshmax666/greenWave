import AsyncStorage from '@react-native-async-storage/async-storage';
import type { RouteResult } from './ors';

const KEY = 'current_route';

export async function loadRoute(): Promise<RouteResult | null> {
  const json = await AsyncStorage.getItem(KEY);
  if (!json) return null;
  try {
    return JSON.parse(json) as RouteResult;
  } catch {
    return null;
  }
}

export async function saveRoute(route: RouteResult): Promise<void> {
  await AsyncStorage.setItem(KEY, JSON.stringify(route));
}
