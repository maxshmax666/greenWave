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
    validation: {
      title: 'Validation',
      light: {
        nameRequired: 'Name is required',
        directionInvalid: 'Direction is invalid',
      },
      cycle: {
        numeric: 'All numeric fields must be valid numbers',
        mainOrder: 'Main start must be less than end',
        secondaryOrder: 'Secondary start must be less than end',
        pedestrianOrder: 'Pedestrian start must be less than end',
      },
    },
    hud: {
      maneuver: '%{maneuver} in %{distance}m',
      speed: 'Speed: %{speed}',
      limit: 'Limit: %{limit}',
      eta: 'ETA: %{eta}s',
    },
    common: {
      save: 'Save',
      cancel: 'Cancel',
    },
    lightForm: {
      name: 'Name',
      direction: 'Direction',
    },
    cycleForm: {
      cycleSeconds: 'Cycle seconds',
      t0: 't0 ISO',
      main: 'Main green start/end',
      secondary: 'Secondary green start/end',
      pedestrian: 'Pedestrian green start/end',
    },
    directions: {
      MAIN: 'MAIN',
      SECONDARY: 'SECONDARY',
      PEDESTRIAN: 'PEDESTRIAN',
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
    validation: {
      title: 'Проверка',
      light: {
        nameRequired: 'Требуется название',
        directionInvalid: 'Неверное направление',
      },
      cycle: {
        numeric: 'Все числовые поля должны быть валидными числами',
        mainOrder: 'Начало основного должно быть меньше конца',
        secondaryOrder: 'Начало вторичного должно быть меньше конца',
        pedestrianOrder: 'Начало пешеходного должно быть меньше конца',
      },
    },
    hud: {
      maneuver: '%{maneuver} через %{distance}м',
      speed: 'Скорость: %{speed}',
      limit: 'Лимит: %{limit}',
      eta: 'ETA: %{eta}с',
    },
    common: {
      save: 'Сохранить',
      cancel: 'Отмена',
    },
    lightForm: {
      name: 'Название',
      direction: 'Направление',
    },
    cycleForm: {
      cycleSeconds: 'Длина цикла',
      t0: 't0 (ISO)',
      main: 'Основной зелёный начало/конец',
      secondary: 'Вторичный зелёный начало/конец',
      pedestrian: 'Пешеходный зелёный начало/конец',
    },
    directions: {
      MAIN: 'ОСНОВНОЙ',
      SECONDARY: 'ВТОРОСТЕПЕННЫЙ',
      PEDESTRIAN: 'ПЕШЕХОДНЫЙ',
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
