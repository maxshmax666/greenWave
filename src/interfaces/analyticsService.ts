export interface AnalyticsService {
  trackEvent(name: string, params?: Record<string, unknown>): Promise<void>;
}
