import { useCallback, useEffect, useRef, useState } from 'react';
import Tflite from 'tflite-react-native';
import type { CameraView, CameraCapturedPicture } from 'expo-camera';
import {
  finalizePhase,
  ColorPhase,
} from '../../../services/traffic/colorPhases';
import { uploadLightCycle } from '../../../services/traffic/lightCycleUploader';

export interface TrafficLightDetection {
  color: 'red' | 'yellow' | 'green';
  boundingBox: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

interface ModelResult {
  detectedClass: string;
  rect: { x: number; y: number; w: number; h: number };
}

export function useLightDetector(
  light: { id: number | string; lat: number; lon: number } | null,
) {
  const cameraRef = useRef<CameraView | null>(null);
  const modelRef = useRef<Tflite | null>(null);
  const [detection, setDetection] = useState<TrafficLightDetection | null>(
    null,
  );
  const [isRecording, setIsRecording] = useState(false);
  const [currentColor, setCurrentColor] = useState<string | null>(null);
  const [colorStartTime, setColorStartTime] = useState<number | null>(null);
  const colorTimeline = useRef<ColorPhase[]>([]);

  const detect = useCallback(
    async (
      photo: CameraCapturedPicture | null,
    ): Promise<TrafficLightDetection | null> => {
      if (!photo?.base64) return null;
      try {
        if (!modelRef.current) {
          const model = new Tflite();
          await new Promise((resolve, reject) => {
            model.loadModel(
              {
                model: 'traffic_light.tflite',
                labels: 'traffic_light_labels.txt',
              },
              (err) => (err ? reject(err) : resolve(null)),
            );
          });
          modelRef.current = model;
        }
        const res = await new Promise<ModelResult[]>((resolve, reject) => {
          modelRef.current!.runModelOnImage(
            { image: photo.base64, numResults: 1, threshold: 0.4 },
            (err, output) =>
              err ? reject(err) : resolve(output as ModelResult[]),
          );
        });
        if (!res.length) return null;
        const [best] = res;
        return {
          color: best.detectedClass as 'red' | 'yellow' | 'green',
          boundingBox: {
            x: best.rect.x,
            y: best.rect.y,
            width: best.rect.w,
            height: best.rect.h,
          },
        };
      } catch {
        return null;
      }
    },
    [],
  );

  useEffect(() => {
    let interval: NodeJS.Timeout | null = null;
    if (isRecording) {
      interval = setInterval(async () => {
        if (!cameraRef.current) return;
        try {
          const photo = await cameraRef.current.takePictureAsync({
            skipProcessing: true,
            base64: true,
          });
          const result = await detect(photo ?? null);
          setDetection(result);
          if (result?.color && result.color !== currentColor) {
            const now = Date.now();
            finalizePhase(
              colorTimeline.current,
              currentColor,
              colorStartTime,
              now,
            );
            setCurrentColor(result.color);
            setColorStartTime(now);
          }
        } catch (e) {
          console.warn('Capture failed', e);
        }
      }, 1000);
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isRecording, detect, currentColor, colorStartTime]);

  const toggleRecording = useCallback(async () => {
    if (isRecording) {
      setIsRecording(false);
      const end = Date.now();
      finalizePhase(colorTimeline.current, currentColor, colorStartTime, end);
      try {
        await uploadLightCycle(light, colorTimeline.current);
      } catch (e) {
        console.warn('Uploading cycle failed', e);
      }
      colorTimeline.current = [];
      setCurrentColor(null);
      setColorStartTime(null);
    } else {
      colorTimeline.current = [];
      setCurrentColor(null);
      setColorStartTime(null);
      setIsRecording(true);
    }
  }, [isRecording, light, currentColor, colorStartTime]);

  return { cameraRef, detection, isRecording, toggleRecording, detect };
}

export default useLightDetector;
