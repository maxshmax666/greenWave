import { fetchWithTimeout } from '../network';

describe('fetchWithTimeout', () => {
  const originalFetch = global.fetch;

  afterEach(() => {
    jest.useRealTimers();
    global.fetch = originalFetch;
    jest.clearAllMocks();
  });

  it('throws on timeout', async () => {
    jest.useFakeTimers();

    global.fetch = jest.fn(
      (_: RequestInfo | URL, init?: RequestInit) =>
        new Promise<Response>((_, reject) => {
          init?.signal?.addEventListener('abort', () => {
            const err = new Error('Aborted');
            err.name = 'AbortError';
            reject(err);
          });
        }),
    ) as unknown as typeof fetch;

    const p = fetchWithTimeout('https://example.com', { timeout: 50 });
    jest.advanceTimersByTime(60);
    await expect(p).rejects.toThrow('Request timed out');
  });

  it('formats error for JSON responses', async () => {
    global.fetch = jest.fn().mockResolvedValue(
      new Response(JSON.stringify({ message: 'Missing' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      }),
    );

    await expect(fetchWithTimeout('https://example.com')).rejects.toThrow(
      'Request failed with status 404: Missing',
    );
  });

  it('formats error for text responses', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: false,
      status: 500,
      json: async () => {
        throw new Error('bad json');
      },
      text: async () => 'Server error',
    } as unknown as Response);

    await expect(fetchWithTimeout('https://example.com')).rejects.toThrow(
      'Request failed with status 500: Server error',
    );
  });
});
