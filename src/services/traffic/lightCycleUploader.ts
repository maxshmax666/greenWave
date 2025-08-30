import AsyncStorage from '@react-native-async-storage/async-storage';
import { uploadCycle, Phase } from './uploadLightData';
import { ColorPhase } from './colorPhases';

export async function uploadLightCycle(
  light: { id: number | string; lat: number; lon: number } | null,
  phases: ColorPhase[],
): Promise<void> {
  await AsyncStorage.setItem('colorPhases', JSON.stringify(phases));
  if (light) {
    await uploadCycle(light.id, light.lat, light.lon, phases as Phase[]);
  }
}
