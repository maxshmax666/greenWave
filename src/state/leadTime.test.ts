import AsyncStorage from '@react-native-async-storage/async-storage';
import * as lead from './leadTime';

const { setLeadTimeSec, loadLeadTimeSec } = lead;

jest.mock('@react-native-async-storage/async-storage', () => {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  return require('@react-native-async-storage/async-storage/jest/async-storage-mock');
});

beforeEach(async () => {
  await AsyncStorage.clear();
});

describe('leadTime state', () => {
  it('loads value from storage', async () => {
    await AsyncStorage.setItem('lead_time_sec', '3');
    await loadLeadTimeSec();
    expect(lead.leadTimeSec).toBe(3);
  });

  it('saves value to storage', async () => {
    await setLeadTimeSec(4);
    expect(await AsyncStorage.getItem('lead_time_sec')).toBe('4');
  });
});
