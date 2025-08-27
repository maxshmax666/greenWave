import { appendFileSync, existsSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';

const logPath = join('data', 'app.log');

function ensureDir(filePath: string) {
  const dir = dirname(filePath);
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true });
  }
}

export type LogLevel = 'INFO' | 'WARN' | 'ERROR';

export function log(level: LogLevel, message: string): void {
  ensureDir(logPath);
  const line = `${new Date().toISOString()} ${level} ${message}\n`;
  appendFileSync(logPath, line);
}
