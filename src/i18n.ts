import { I18n } from 'i18n-js';
import * as Localization from 'expo-localization';

const translations = {
  en: require('./locales/en.json'),
  ru: require('./locales/ru.json'),
};

const i18n = new I18n(translations);
i18n.enableFallback = true;

const locales = Localization.getLocales();
if (locales.length > 0) {
  i18n.locale = locales[0].languageTag.split('-')[0];
}

export default i18n;
