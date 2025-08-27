
import Tflite from 'tflite-react-native';

export interface TrafficLightDetection {
  color: 'red' | 'yellow' | 'green';
  boundingBox: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

let model: Tflite | null = null;

async function getModel(): Promise<Tflite> {
  if (model) return model;
  model = new Tflite();
  await new Promise((resolve, reject) => {
    model!.loadModel(
      {
        model: 'traffic_light.tflite',
        labels: 'traffic_light_labels.txt',
      },
      err => (err ? reject(err) : resolve(null)),
    );
  });
  return model!;
}

export async function detectTrafficLight(
  photo: { base64?: string } | null,
): Promise<TrafficLightDetection | null> {
  if (!photo?.base64) return null;
  try {
    const tflite = await getModel();
    const res = await new Promise<any[]>((resolve, reject) => {
      tflite.runModelOnImage(
        {
          image: photo.base64,
          numResults: 1,
          threshold: 0.4,
        },
        (err, output) => (err ? reject(err) : resolve(output)),
      );
    });
    if (!res || res.length === 0) return null;
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
}
