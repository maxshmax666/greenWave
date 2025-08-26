jest.mock(
  'expo-localization',
  () => ({ getLocales: () => [{ languageTag: 'en-US' }] }),
  { virtual: true }
);

import i18n from './i18n';

describe('i18n translations', () => {
  it('renders Russian recommendation', () => {
    i18n.locale = 'ru';
    const res = i18n.t('speedBanner.recommendation', {
      speed: 40,
      distance: 100,
      time: 20,
    });
    expect(res).toBe(
      'Рекомендуем 40 км/ч • ближайший светофор через 100 м • окно через 20 с'
    );
  });

  it('renders English recommendation', () => {
    i18n.locale = 'en';
    const res = i18n.t('speedBanner.recommendation', {
      speed: 40,
      distance: 100,
      time: 20,
    });
    expect(res).toBe(
      'Recommend 40 km/h • next light in 100 m • window in 20 s'
    );
  });
});
