export function parseMessage(raw: string): unknown {
  return JSON.parse(raw);
}
