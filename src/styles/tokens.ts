export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
} as const;

export const radius = {
  sm: 4,
  md: 8,
  lg: 12,
} as const;

export const colors = {
  light: {
    background: '#ffffff',
    text: '#000000',
    card: '#f5f5f5',
  },
  dark: {
    background: '#000000',
    text: '#ffffff',
    card: '#333333',
  },
} as const;

export type ThemeName = keyof typeof colors;
