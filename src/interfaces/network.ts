export interface FetchOptions extends RequestInit {
  timeout?: number;
}

export interface Network {
  fetchWithTimeout(
    input: RequestInfo | URL,
    options?: FetchOptions,
  ): Promise<Response>;
}
