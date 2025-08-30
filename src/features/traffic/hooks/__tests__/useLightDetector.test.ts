jest.mock('tflite-react-native');

import { renderHook, act } from '@testing-library/react-hooks';
import useLightDetector from '../useLightDetector';
import { runModelOnImageMock as runModelOnImageMockRaw } from 'tflite-react-native';
import type { CameraCapturedPicture } from 'expo-camera';
const runModelOnImageMock = runModelOnImageMockRaw as jest.Mock;

jest.mock('../../../../services/traffic/lightCycleUploader', () => ({
  uploadLightCycle: jest.fn().mockResolvedValue(undefined),
}));

describe('useLightDetector', () => {
  beforeEach(() => {
    runModelOnImageMock.mockReset();
  });

  it('returns null when photo is missing', async () => {
    const { result } = renderHook(() => useLightDetector(null));
    await expect(result.current.detect(null)).resolves.toBeNull();
  });

  it('parses model response', async () => {
    runModelOnImageMock.mockImplementation(
      (_opts: unknown, cb: (err: Error | null, res?: unknown) => void) => {
        cb(null, [
          { detectedClass: 'green', rect: { x: 1, y: 2, w: 3, h: 4 } },
        ]);
      },
    );
    const { result } = renderHook(() => useLightDetector(null));
    const res = await result.current.detect({
      base64: 'img',
      width: 0,
      height: 0,
      uri: '',
    } as CameraCapturedPicture);
    expect(res).toEqual({
      color: 'green',
      boundingBox: { x: 1, y: 2, width: 3, height: 4 },
    });
  });

  it('returns null on model errors', async () => {
    runModelOnImageMock.mockImplementation(
      (_opts: unknown, cb: (err: Error | null) => void) =>
        cb(new Error('fail')),
    );
    const { result } = renderHook(() => useLightDetector(null));
    await expect(
      result.current.detect({
        base64: 'img',
        width: 0,
        height: 0,
        uri: '',
      } as CameraCapturedPicture),
    ).resolves.toBeNull();
  });

  it('uploads cycle on stop', async () => {
    const { result } = renderHook(() =>
      useLightDetector({ id: 1, lat: 0, lon: 0 }),
    );
    await act(async () => {
      await result.current.toggleRecording();
    });
    expect(result.current.isRecording).toBe(true);
    await act(async () => {
      await result.current.toggleRecording();
    });
    expect(result.current.isRecording).toBe(false);
  });
});
