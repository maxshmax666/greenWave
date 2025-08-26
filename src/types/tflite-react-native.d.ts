declare module 'tflite-react-native' {
  export default class Tflite {
    loadModel(
      opts: any,
      cb: (err: string | null, res?: any) => void,
    ): void;
    runModelOnImage(
      opts: any,
      cb: (err: string | null, res?: any) => void,
    ): void;
  }
  export const runModelOnImageMock: any;
  export const loadModelMock: any;
}
