import { log } from '../logger';
import type { HandlerMap } from './types';

export const handlers: HandlerMap = {
  ping: async () => {
    await log('INFO', 'received ping');
  },
};

export default handlers;
