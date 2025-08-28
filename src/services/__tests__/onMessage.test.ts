import {
  parseMessage,
  validateMessage,
  handleMessage,
  onMessage,
} from '../onMessage';
import { log } from '../logger';

jest.mock('../logger', () => ({
  log: jest.fn().mockResolvedValue(undefined),
}));

describe('parseMessage', () => {
  it('parses JSON string', () => {
    expect(parseMessage('{"type":"ping"}')).toEqual({ type: 'ping' });
  });

  it('throws on invalid JSON', () => {
    expect(() => parseMessage('bad')).toThrow();
  });
});

describe('validateMessage', () => {
  it('returns message when type exists', () => {
    expect(validateMessage({ type: 'ping', payload: 1 })).toEqual({
      type: 'ping',
      payload: 1,
    });
  });

  it('throws when type missing', () => {
    expect(() => validateMessage({})).toThrow('Invalid message');
  });
});

describe('handleMessage', () => {
  it('logs received type', async () => {
    await handleMessage({ type: 'ping' });
    expect(log).toHaveBeenCalledWith('INFO', 'received ping');
  });
});

describe('onMessage', () => {
  beforeEach(() => {
    (log as jest.Mock).mockClear();
  });

  it('runs full pipeline', async () => {
    await onMessage('{"type":"ping"}');
    expect(log).toHaveBeenCalledWith('INFO', 'received ping');
  });

  it('throws on invalid JSON and skips logging', async () => {
    await expect(onMessage('bad')).rejects.toThrow();
    expect(log).not.toHaveBeenCalled();
  });

  it('throws on missing type and skips logging', async () => {
    await expect(onMessage('{}')).rejects.toThrow('Invalid message');
    expect(log).not.toHaveBeenCalled();
  });
});
