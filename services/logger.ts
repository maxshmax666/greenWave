let FileSystem: any;
let fs: typeof import('fs') | null = null;
let path: typeof import('path') | null = null;

try {
  FileSystem = require('expo-file-system');
} catch {
  fs = require('fs');
  path = require('path');
}

export type LogLevel = 'INFO' | 'WARN' | 'ERROR';

const logFile = FileSystem
  ? `${FileSystem.documentDirectory}data/app.log`
  : path!.join('data', 'app.log');

function pad(n: number): string {
  return n.toString().padStart(2, '0');
}

function formatDate(d: Date): string {
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())} ${pad(
    d.getUTCHours(),
  )}:${pad(d.getUTCMinutes())}:${pad(d.getUTCSeconds())}`;
}

async function ensureDir(file: string): Promise<void> {
  if (FileSystem) {
    const dir = `${FileSystem.documentDirectory}data`;
    await FileSystem.makeDirectoryAsync(dir, { intermediates: true });
  } else if (fs && path) {
    const dir = path.dirname(file);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }
}

export async function log(level: LogLevel, message: string): Promise<void> {
  const line = `${formatDate(new Date())} [${level}] ${message}\n`;
  await ensureDir(logFile);
  if (FileSystem) {
    await FileSystem.writeAsStringAsync(logFile, line, {
      encoding: FileSystem.EncodingType.UTF8,
      append: true,
    });
  } else if (fs) {
    fs.appendFileSync(logFile, line);
  }
}
