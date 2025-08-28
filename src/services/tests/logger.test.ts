import path from 'path';

jest.mock('expo-file-system', () => ({
  writeAsStringAsync: jest.fn(),
  makeDirectoryAsync: jest.fn(),
  documentDirectory: '/doc/',
  EncodingType: { UTF8: 'utf8' },
}));

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

  it('appends formatted line with expo-file-system', async () => {
    const { log } = await import('../logger');
    const FileSystem = await import('expo-file-system');
    await log('INFO', 'hello');
    expect(FileSystem.makeDirectoryAsync).toHaveBeenCalledWith('/doc/data', {
      intermediates: true,
    });
    expect(FileSystem.writeAsStringAsync).toHaveBeenCalledWith(
      `${FileSystem.documentDirectory}data/app.log`,
      '2023-01-02 03:04:05 [INFO] hello\n',
      {
        encoding: FileSystem.EncodingType.UTF8,
        append: true,
      },
    );
  });

  it('appends formatted line with fs', async () => {
    const FileSystem = await import('expo-file-system');
    (FileSystem.writeAsStringAsync as jest.Mock).mockRejectedValueOnce(
      new Error('fail'),
    );
    jest.mock('fs', () => ({
      appendFileSync: jest.fn(),
      existsSync: jest.fn().mockReturnValue(true),
      mkdirSync: jest.fn(),
    }));
    const { log } = await import('../logger');
    const fs = await import('fs');
    await log('INFO', 'hello');
    expect(fs.appendFileSync).toHaveBeenCalledWith(
      path.join('data', 'app.log'),
      '2023-01-02 03:04:05 [INFO] hello\n',
    );
  });
});
