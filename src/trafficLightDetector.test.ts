jest.mock('tflite-react-native');

import { detectTrafficLight } from '../services/trafficLightDetector';
import { runModelOnImageMock } from 'tflite-react-native';

describe('detectTrafficLight', () => {
  beforeEach(() => {
    runModelOnImageMock.mockReset();
  });

  it('returns null when photo is missing', async () => {
    await expect(detectTrafficLight(null)).resolves.toBeNull();
  });

  it('parses model response', async () => {
    runModelOnImageMock.mockImplementation((opts: any, cb: any) => {
      cb(null, [
        { detectedClass: 'green', rect: { x: 1, y: 2, w: 3, h: 4 } },
      ]);
    });
    const res = await detectTrafficLight({ base64: 'img' });
    expect(res).toEqual({
      color: 'green',
      boundingBox: { x: 1, y: 2, width: 3, height: 4 },
    });
  });

  it('returns null on model errors', async () => {
    runModelOnImageMock.mockImplementation((opts: any, cb: any) => cb(new Error('fail')));
    await expect(detectTrafficLight({ base64: 'img' })).resolves.toBeNull();
  });
});
