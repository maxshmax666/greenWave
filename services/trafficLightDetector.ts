
export interface TrafficLightDetection {
  color: 'red' | 'yellow' | 'green';
  boundingBox: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

// Placeholder for TFLite/ML Kit integration. Replace with actual model inference.
export async function detectTrafficLight(
  photo: { base64?: string } | null,
): Promise<TrafficLightDetection | null> {
  if (!photo) return null;
  // TODO: integrate TFLite/ML Kit model to detect traffic lights
  return {
    color: 'red',
    boundingBox: { x: 0.5, y: 0.5, width: 0.1, height: 0.2 },
  };
}
