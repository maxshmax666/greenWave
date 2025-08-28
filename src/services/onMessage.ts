import { log } from './logger';

export interface Message {
  type: string;
  payload?: unknown;
}

export function parseMessage(raw: string): unknown {
  return JSON.parse(raw);
}

export function validateMessage(data: unknown): Message {
  if (
    !data ||
    typeof data !== 'object' ||
    Array.isArray(data) ||
    typeof (data as { type?: unknown }).type !== 'string'
  ) {
    throw new Error('Invalid message');
  }
  return data as Message;
}

export async function handleMessage(message: Message): Promise<void> {
  await log('INFO', `received ${message.type}`);
}

export async function onMessage(raw: string): Promise<void> {
  const data = parseMessage(raw);
  const message = validateMessage(data);
  await handleMessage(message);
}

export default onMessage;
