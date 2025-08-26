const runModelOnImageMock = jest.fn();
const loadModelMock = jest.fn((_: any, cb: (err: any, res?: any) => void) => cb(null, true));

class TfliteMock {
  loadModel = loadModelMock;
  runModelOnImage = runModelOnImageMock;
}

export default TfliteMock;
export { runModelOnImageMock, loadModelMock };
