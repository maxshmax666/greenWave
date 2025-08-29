import { createGptClient } from '../apiClient';
import * as logger from '../../logger';

describe('createGptClient', () => {
  it('calls fetch with correct payload and returns text', async () => {
    const mockFetch = jest
      .fn<ReturnType<typeof fetch>, Parameters<typeof fetch>>()
      .mockResolvedValue({
        ok: true,
        json: async () => ({ choices: [{ message: { content: 'ok' } }] }),
      } as unknown as Response);
    const client = createGptClient('k', mockFetch);
    const text = await client.complete('hi');
    expect(mockFetch).toHaveBeenCalledWith(
      'https://api.openai.com/v1/chat/completions',
      expect.objectContaining({ method: 'POST' }),
    );
    expect(text).toBe('ok');
  });

  it('throws error text when response not ok', async () => {
    const mockFetch = jest
      .fn<ReturnType<typeof fetch>, Parameters<typeof fetch>>()
      .mockResolvedValue({
        ok: false,
        text: async () => 'err',
      } as unknown as Response);
    const client = createGptClient('k', mockFetch);
    const expected = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer k',
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: 'hi' }],
      }),
    };
    await expect(client.complete('hi')).rejects.toThrow('err');
    expect(mockFetch).toHaveBeenCalledWith(
      'https://api.openai.com/v1/chat/completions',
      expected,
    );
  });

  it('logs and rethrows on json parse error', async () => {
    const mockFetch = jest
      .fn<ReturnType<typeof fetch>, Parameters<typeof fetch>>()
      .mockResolvedValue({
        ok: true,
        json: async () => {
          throw new Error('nojson');
        },
      } as unknown as Response);
    const logSpy = jest.spyOn(logger, 'log').mockResolvedValue(undefined);
    const client = createGptClient('k', mockFetch);
    await expect(client.complete('hi')).rejects.toThrow('nojson');
    expect(logSpy).toHaveBeenCalledWith(
      'ERROR',
      expect.stringContaining('nojson'),
    );
    logSpy.mockRestore();
  });
});
