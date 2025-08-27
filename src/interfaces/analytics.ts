export interface Analytics {
  trackEvent(name: string, params?: Record<string, unknown>): Promise<void>;
}
