import AsyncStorage from '@react-native-async-storage/async-storage';
import type { Store } from '../interfaces/stores';

const KEY = 'lead_time_sec';

export const leadTimeStore: Store<number> = {
  async get() {
    const stored = await AsyncStorage.getItem(KEY);
    const parsed = stored ? parseInt(stored, 10) : NaN;
    return Number.isNaN(parsed) ? 0 : parsed;
  },
  async set(value: number) {
    await AsyncStorage.setItem(KEY, value.toString());
  },
};
