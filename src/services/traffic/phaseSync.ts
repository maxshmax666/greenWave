import AsyncStorage from '@react-native-async-storage/async-storage';
import { network } from '../network';
import type { PhaseRecord, PhaseSync } from '../../interfaces/phaseSync';

export const STORAGE_KEY = 'voicePhases';
const ENDPOINT = 'https://example.com/api/phases';

export const phaseSync: PhaseSync = {
  async syncPhases() {
    const raw = await AsyncStorage.getItem(STORAGE_KEY);
    if (!raw) return;
    const phases: PhaseRecord[] = JSON.parse(raw);
    if (!phases.length) return;
    await network.fetchWithTimeout(ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phases }),
    });
    await AsyncStorage.removeItem(STORAGE_KEY);
  },
};

export const syncPhases = phaseSync.syncPhases;
