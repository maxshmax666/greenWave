import { log } from '../logger';
import type { Message } from './types';

export async function handleMessage(message: Message): Promise<void> {
  await log('INFO', `received ${message.type}`);
}
