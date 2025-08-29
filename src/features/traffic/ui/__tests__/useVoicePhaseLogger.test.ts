import AsyncStorage from '@react-native-async-storage/async-storage';
import { parseVoiceResult } from '../useVoicePhaseLogger';
import { phaseSync, STORAGE_KEY } from '../../services/phaseSync';
import { network } from '../../../../services/network';

jest.mock(
  'expo-voice',
  () => ({
    startAsync: jest.fn(),
    stopAsync: jest.fn(async () => ''),
  }),
  { virtual: true },
);

jest.mock('@react-native-async-storage/async-storage', () =>
  jest.requireActual(
    '@react-native-async-storage/async-storage/jest/async-storage-mock',
  ),
);

jest.mock('../../../../services/network', () => ({
  network: { fetchWithTimeout: jest.fn().mockResolvedValue({ ok: true }) },
}));

describe('parseVoiceResult', () => {
  it('parses color and time', () => {
    expect(parseVoiceResult('green 12')).toEqual({
      color: 'green',
      startTime: 12,
    });
  });

  it('returns null for invalid input', () => {
    expect(parseVoiceResult('invalid')).toBeNull();
  });
});

describe('phaseSync', () => {
  it('uploads stored phases and clears storage', async () => {
    await AsyncStorage.setItem(
      STORAGE_KEY,
      JSON.stringify([{ color: 'red', startTime: 1 }]),
    );
    await phaseSync.syncPhases();
    expect(network.fetchWithTimeout).toHaveBeenCalled();
    expect(AsyncStorage.getItem).toHaveBeenCalledWith(STORAGE_KEY);
    expect(AsyncStorage.removeItem).toHaveBeenCalledWith(STORAGE_KEY);
  });
});
