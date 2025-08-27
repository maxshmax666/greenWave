jest.mock('@supabase/supabase-js', () => ({
  createClient: jest.fn(() => ({
    from: jest.fn(),
    channel: jest.fn(() => ({
      on: jest.fn().mockReturnThis(),
      subscribe: jest.fn(),
    })),
    removeChannel: jest.fn(),
  })),
}));

describe('fetchLightsAndCycles error handling', () => {
  beforeEach(() => {
    jest.resetModules();
  });
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('returns error when fetching lights fails', async () => {
    const logger = await import('./services/logger');
    const logSpy = jest.spyOn(logger, 'log').mockResolvedValue(undefined);
    const { supabaseService, supabase } = await import('./services/supabase');
    const { fetchLightsAndCycles } = supabaseService;
    const originalFrom = supabase.from;

    supabase.from = jest.fn().mockReturnValue({
      select: jest
        .fn()
        .mockResolvedValue({ data: null, error: new Error('lights') }),
    });

    const res = await fetchLightsAndCycles();
    expect(res.error).toBeTruthy();
    expect(logSpy).toHaveBeenCalledWith(
      'ERROR',
      'Error fetching lights: lights',
    );

    supabase.from = originalFrom;
  });

  it('returns error when fetching cycles fails', async () => {
    const logger = await import('./services/logger');
    const logSpy = jest.spyOn(logger, 'log').mockResolvedValue(undefined);
    const { supabaseService, supabase } = await import('./services/supabase');
    const { fetchLightsAndCycles } = supabaseService;
    const originalFrom = supabase.from;

    supabase.from = jest
      .fn()
      .mockImplementationOnce(() => ({
        select: jest.fn().mockResolvedValue({ data: [], error: null }),
      }))
      .mockImplementationOnce(() => ({
        select: jest
          .fn()
          .mockResolvedValue({ data: null, error: new Error('cycles') }),
      }));

    const res = await fetchLightsAndCycles();
    expect(res.error).toBeTruthy();
    expect(logSpy).toHaveBeenCalledWith(
      'ERROR',
      'Error fetching cycles: cycles',
    );

    supabase.from = originalFrom;
  });
});
