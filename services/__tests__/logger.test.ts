import { readFileSync, existsSync, unlinkSync } from 'fs';
import { log } from '../logger';

describe('log', () => {
  const logFile = 'data/app.log';
  afterEach(() => {
    if (existsSync(logFile)) {
      unlinkSync(logFile);
    }
  });

  it('writes message with level and timestamp', () => {
    log('INFO', 'hello');
    const content = readFileSync(logFile, 'utf8');
    expect(content).toMatch(/INFO hello/);
  });
});
