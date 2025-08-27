import { getRoute } from '../services/ors';

const start = { latitude: 1, longitude: 2 };
const end = { latitude: 3, longitude: 4 };

describe('getRoute', () => {
  beforeEach(() => {
    process.env.EXPO_PUBLIC_ORS_API_KEY = 'test-key';
  });

  afterEach(() => {
    jest.restoreAllMocks();
    delete process.env.EXPO_PUBLIC_ORS_API_KEY;
  });

  it('throws when API key is missing', async () => {
    delete process.env.EXPO_PUBLIC_ORS_API_KEY;
    const fetchSpy = jest.spyOn(global, 'fetch');
    await expect(getRoute(start, end)).rejects.toThrow(
      'EXPO_PUBLIC_ORS_API_KEY is required',
    );
    expect(fetchSpy).not.toHaveBeenCalled();
  });

  it('throws on non-ok responses', async () => {
    const fetchSpy = jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: false,
      status: 500,
      text: jest.fn().mockResolvedValue('server error'),
    } as unknown as Response);

    await expect(getRoute(start, end)).rejects.toThrow(
      'Unable to fetch route. Request failed with status 500: server error',
    );
    expect(fetchSpy).toHaveBeenCalledTimes(1);
  });
});
