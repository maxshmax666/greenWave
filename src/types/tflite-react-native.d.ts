declare module 'tflite-react-native' {
  export default class Tflite {
    loadModel(
      opts: unknown,
      cb: (err: string | null, res?: unknown) => void,
    ): void;
    runModelOnImage(
      opts: unknown,
      cb: (err: string | null, res?: unknown) => void,
    ): void;
  }
  export const runModelOnImageMock: (
    opts: unknown,
    cb: (err: Error | null, res?: unknown) => void,
  ) => void;
  export const loadModelMock: (
    opts: unknown,
    cb: (err: Error | null, res?: unknown) => void,
  ) => void;
}
