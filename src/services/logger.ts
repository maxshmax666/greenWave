export type LogLevel = 'INFO' | 'WARN' | 'ERROR';

function pad(n: number): string {
  return n.toString().padStart(2, '0');
}

function formatDate(d: Date): string {
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())} ${pad(
    d.getUTCHours(),
  )}:${pad(d.getUTCMinutes())}:${pad(d.getUTCSeconds())}`;
}

export async function log(level: LogLevel, message: string): Promise<void> {
  const line = `${formatDate(new Date())} [${level}] ${message}\n`;
  try {
    const FileSystem = await import('expo-file-system');
    const file = `${FileSystem.documentDirectory}data/app.log`;
    const dir = `${FileSystem.documentDirectory}data`;
    await FileSystem.makeDirectoryAsync(dir, { intermediates: true });
    await FileSystem.writeAsStringAsync(file, line, {
      encoding: FileSystem.EncodingType.UTF8,
      append: true,
    } as import('expo-file-system').WritingOptions & { append: boolean });
  } catch {
    const fs = await import('fs');
    const path = await import('path');
    const file = path.join('data', 'app.log');
    const dir = path.dirname(file);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.appendFileSync(file, line);
  }
}
