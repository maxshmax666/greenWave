import { I18n } from 'i18n-js';
import * as Localization from 'expo-localization';

const translations = {
  en: {
    speedBanner: {
      recommendation: 'Recommend %{speed} km/h • next light in %{distance} m • window in %{time} s',
    },
    menu: {
      startNavigation: 'Start Navigation',
      clearRoute: 'Clear Route',
      addLight: 'Add Light',
      settings: 'Settings',
    },
  },
  ru: {
    speedBanner: {
      recommendation: 'Рекомендуем %{speed} км/ч • ближайший светофор через %{distance} м • окно через %{time} с',
    },
    menu: {
      startNavigation: 'Начать навигацию',
      clearRoute: 'Очистить маршрут',
      addLight: 'Добавить светофор',
      settings: 'Настройки',
    },
  },
};

const i18n = new I18n(translations);
i18n.enableFallback = true;

const locales = Localization.getLocales();
if (locales.length > 0) {
  i18n.locale = locales[0].languageTag.split('-')[0];
}

export default i18n;
