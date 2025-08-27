declare module 'expo-notifications' {
  interface NotificationOptions {
    content: { title: string; body: string };
    trigger: null | number | Date | Record<string, unknown>;
  }

  export function scheduleNotificationAsync(
    options: NotificationOptions,
  ): Promise<string>;

  export function requestPermissionsAsync(): Promise<{
    status: 'granted' | 'denied';
  }>;
}
