import { getRoute } from './ors';
import { network } from '../../../services/network';

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

  it('returns parsed route data on success', async () => {
    const json = {
      features: [
        {
          geometry: { coordinates: [[2, 1], [4, 3]] },
          properties: {
            summary: { distance: 100, duration: 200 },
            segments: [
              {
                steps: [
                  {
                    instruction: 'Head north',
                    distance: 100,
                    duration: 200,
                    name: 'Main St',
                    speed: 50,
                  },
                ],
              },
            ],
          },
        },
      ],
    };
    const fetchSpy = jest
      .spyOn(network, 'fetchWithTimeout')
      .mockResolvedValue({ json: async () => json } as any);

    const route = await getRoute(start, end);

    expect(route).toEqual({
      geometry: [
        { latitude: 1, longitude: 2 },
        { latitude: 3, longitude: 4 },
      ],
      distance: 100,
      duration: 200,
      steps: [
        {
          instruction: 'Head north',
          distance: 100,
          duration: 200,
          name: 'Main St',
          speed: 50,
        },
      ],
    });
    expect(fetchSpy).toHaveBeenCalledTimes(1);
  });
});
