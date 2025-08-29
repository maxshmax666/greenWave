import fs from 'fs';
import { log } from '../logger';

describe('logger', () => {
  const file = 'data/app.log';

  beforeEach(() => {
    fs.rmSync('data', { recursive: true, force: true });
  });

  it('writes formatted log line', async () => {
    const level = 'INFO';
    const message = 'test message';
    await log(level, message);
    const content = fs.readFileSync(file, 'utf8').trim();
    const line = content.split('\n').pop();
    const pattern = new RegExp(
      `^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2} \\[${level}\\] ${message}$`,
    );
    expect(line).toMatch(pattern);
  });
});
