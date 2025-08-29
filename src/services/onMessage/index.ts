import { parseMessage } from './parse';
import { validateMessage } from './validate';
import { handleMessage } from './handle';
export type { Message } from './types';

export { parseMessage, validateMessage, handleMessage };

export async function onMessage(raw: string): Promise<void> {
  const data = parseMessage(raw);
  const message = validateMessage(data);
  await handleMessage(message);
}

export default onMessage;
