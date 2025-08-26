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

  it('translates validation messages', () => {
    i18n.locale = 'en';
    expect(i18n.t('validation.light.nameRequired')).toBe('Name is required');
    i18n.locale = 'ru';
    expect(i18n.t('validation.light.nameRequired')).toBe('Требуется название');
  });

  it('translates HUD speed text', () => {
    i18n.locale = 'en';
    expect(i18n.t('hud.speed', { speed: 50 })).toBe('Speed: 50');
    i18n.locale = 'ru';
    expect(i18n.t('hud.speed', { speed: 50 })).toBe('Скорость: 50');
  });

  it('translates menu labels', () => {
    i18n.locale = 'en';
    expect(i18n.t('menu.startNavigation')).toBe('Start Navigation');
    i18n.locale = 'ru';
    expect(i18n.t('menu.startNavigation')).toBe('Начать навигацию');
  });
});
