jest.mock('@supabase/supabase-js', () => ({
  createClient: jest.fn(() => ({
    from: jest.fn(),
    channel: jest.fn(() => ({ on: jest.fn().mockReturnThis(), subscribe: jest.fn() })),
    removeChannel: jest.fn(),
  })),
}));

describe('fetchLightsAndCycles error handling', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('returns error when fetching lights fails', async () => {
    const { fetchLightsAndCycles, supabase } = require('../services/supabase');
    const originalFrom = supabase.from;
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

    supabase.from = jest.fn().mockReturnValue({
      select: jest.fn().mockResolvedValue({ data: null, error: new Error('lights') }),
    });

    const res = await fetchLightsAndCycles();
    expect(res.error).toBeTruthy();
    expect(consoleSpy).toHaveBeenCalledWith('Error fetching lights:', expect.any(Error));

    supabase.from = originalFrom;
  });

  it('returns error when fetching cycles fails', async () => {
    const { fetchLightsAndCycles, supabase } = require('../services/supabase');
    const originalFrom = supabase.from;
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

    supabase.from = jest
      .fn()
      .mockImplementationOnce(() => ({
        select: jest.fn().mockResolvedValue({ data: [], error: null }),
      }))
      .mockImplementationOnce(() => ({
        select: jest.fn().mockResolvedValue({ data: null, error: new Error('cycles') }),
      }));

    const res = await fetchLightsAndCycles();
    expect(res.error).toBeTruthy();
    expect(consoleSpy).toHaveBeenCalledWith('Error fetching cycles:', expect.any(Error));

    supabase.from = originalFrom;
  });
});

