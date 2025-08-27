import type { Network, FetchOptions } from '../interfaces/network';

export const network: Network = {
  async fetchWithTimeout(input, options = {}) {
    const { timeout = 10000, ...init } = options;
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), timeout);
    try {
      const res = await fetch(input, { ...init, signal: controller.signal });
      if (!res.ok) {
        let message = '';
        try {
          const data = await res.json();
          message = data.message || JSON.stringify(data);
        } catch {
          try {
            message = await res.text();
          } catch {
            /* ignore */
          }
        }
        message = message || res.statusText || 'Unknown error';
        throw new Error(`Request failed with status ${res.status}: ${message}`);
      }
      return res;
    } catch (err: any) {
      if (err.name === 'AbortError') {
        throw new Error('Request timed out. Please try again.');
      }
      throw new Error(err.message || 'Network request failed.');
    } finally {
      clearTimeout(id);
    }
  },
};

export const fetchWithTimeout = network.fetchWithTimeout;
