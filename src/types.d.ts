declare module 'expo-localization';
declare module 'i18n-js';
declare module 'expo-voice' {
  export function startAsync(): Promise<void>;
  export function stopAsync(): Promise<string>;
}
