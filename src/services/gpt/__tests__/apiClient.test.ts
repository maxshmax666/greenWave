import { createGptClient } from '../apiClient';

describe('createGptClient', () => {
  it('calls fetch with correct payload and returns text', async () => {
    const mockFetch = jest
      .fn<ReturnType<typeof fetch>, Parameters<typeof fetch>>()
      .mockResolvedValue({
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
});
