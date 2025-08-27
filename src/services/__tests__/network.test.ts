import { network } from '../network';

const { fetchWithTimeout } = network;

describe('fetchWithTimeout', () => {
  const originalFetch = global.fetch;

  afterEach(() => {
    jest.useRealTimers();
    global.fetch = originalFetch;
    jest.clearAllMocks();
    jest.restoreAllMocks();
  });

  it('aborts the request when timeout elapses', async () => {
    jest.useFakeTimers();
    const abortSpy = jest.spyOn(AbortController.prototype, 'abort');

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
    expect(abortSpy).toHaveBeenCalledTimes(1);
  });

  it('passes custom headers to fetch', async () => {
    const fetchMock = jest
      .fn()
      .mockResolvedValue(new Response(null, { status: 200 }));
    global.fetch = fetchMock as unknown as typeof fetch;

    await fetchWithTimeout('https://example.com', {
      headers: { 'X-Test': 'ok' },
    });

    expect(fetchMock).toHaveBeenCalledWith(
      'https://example.com',
      expect.objectContaining({
        headers: { 'X-Test': 'ok' },
        signal: expect.any(AbortSignal),
      }),
    );
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
