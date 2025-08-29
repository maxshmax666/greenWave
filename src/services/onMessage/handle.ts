import type { Message } from './types';
import { handlers } from './handlers';

export async function handleMessage(message: Message): Promise<void> {
  const handler = handlers[message.type];
  if (handler) {
    await handler(message);
  }
}
