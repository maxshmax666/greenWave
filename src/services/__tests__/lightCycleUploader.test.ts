import AsyncStorage from '@react-native-async-storage/async-storage';
import { uploadLightCycle } from '../lightCycleUploader';
import { uploadCycle } from '../uploadLightData';
import type { ColorPhase } from '../../features/traffic/services/colorPhases';

jest.mock('@react-native-async-storage/async-storage', () =>
  jest.requireActual(
    '@react-native-async-storage/async-storage/jest/async-storage-mock',
  ),
);

jest.mock('../uploadLightData', () => ({
  uploadCycle: jest.fn(),
}));

describe('uploadLightCycle', () => {
  const phases: ColorPhase[] = [{ color: 'red', duration: 1 }];

  it('stores phases', async () => {
    await uploadLightCycle(null, phases);
    expect(AsyncStorage.setItem).toHaveBeenCalled();
    expect(uploadCycle).not.toHaveBeenCalled();
  });

  it('uploads when light provided', async () => {
    await uploadLightCycle({ id: 1, lat: 2, lon: 3 }, phases);
    expect(uploadCycle).toHaveBeenCalledWith(1, 2, 3, phases);
  });
});
