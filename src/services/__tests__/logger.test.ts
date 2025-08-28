import fs from 'fs';
import { log } from '../logger';

describe('logger', () => {
  const file = 'data/app.log';

  beforeEach(() => {
    fs.rmSync('data', { recursive: true, force: true });
  });

  it('writes formatted log line', async () => {
    await log('INFO', 'test message');
    const content = fs.readFileSync(file, 'utf8').trim();
    const line = content.split('\n').pop();
    expect(line).toMatch(
      /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \[INFO\] test message/,
    );
  });
});
