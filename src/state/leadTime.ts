import AsyncStorage from '@react-native-async-storage/async-storage';

const KEY = 'lead_time_sec';

export let leadTimeSec = 0;

export async function setLeadTimeSec(value: number): Promise<void> {
  leadTimeSec = value;
  await AsyncStorage.setItem(KEY, value.toString());
}

export async function loadLeadTimeSec(): Promise<void> {
  const stored = await AsyncStorage.getItem(KEY);
  const parsed = stored ? parseInt(stored, 10) : NaN;
  if (!Number.isNaN(parsed)) leadTimeSec = parsed;
}
