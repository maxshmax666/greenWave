import type { Message } from './types';

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
