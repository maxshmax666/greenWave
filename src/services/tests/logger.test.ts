describe('log', () => {
  const fixed = new Date(Date.UTC(2023, 0, 2, 3, 4, 5));

  beforeEach(() => {
    jest.resetModules();
    jest.useFakeTimers().setSystemTime(fixed);
  });

  afterEach(() => {
    jest.useRealTimers();
    jest.clearAllMocks();
  });

  it('appends formatted line with fs', async () => {
    jest.doMock('fs', () => ({
      appendFileSync: jest.fn(),
      existsSync: jest.fn().mockReturnValue(true),
      mkdirSync: jest.fn(),
    }));

    let log: any;
    let fs: any;
    jest.isolateModules(() => {
      log = require('../logger').log;
      fs = require('fs');
    });
    await log('INFO', 'hello');
    expect(fs.appendFileSync).toHaveBeenCalledWith(
      require('path').join('data', 'app.log'),
      '2023-01-02 03:04:05 [INFO] hello\n',
    );
  });

});
