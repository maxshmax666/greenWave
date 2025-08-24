// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'GreenWave';

  @override
  String get navMap => 'Карта';

  @override
  String get navLights => 'Светофоры';

  @override
  String get navSettings => 'Настройки';

  @override
  String get map => 'Карта';

  @override
  String get lights => 'Светофоры';

  @override
  String get settings => 'Настройки';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get haveAccount => 'У меня уже есть аккаунт';

  @override
  String get email => 'E‑mail';

  @override
  String get password => 'Пароль';

  @override
  String get emailLabel => 'E‑mail';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get emailHint => 'Введите e‑mail';

  @override
  String get passwordHint => 'Введите пароль';

  @override
  String get slogan => 'Лови волну зелёных';

  @override
  String get lightsTitle => 'Светофоры';

  @override
  String failedLoadLights(String error) {
    return 'Не удалось загрузить светофоры: $error';
  }

  @override
  String get noCoords => 'нет координат';

  @override
  String lightWithId(int id) {
    return 'Светофор $id';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get english => 'Английский';

  @override
  String get russian => 'Русский';

  @override
  String get language => 'Язык';

  @override
  String get supabaseUrl => 'Supabase URL';

  @override
  String get supabaseKey => 'Supabase Key';

  @override
  String routeError(String error) {
    return 'Ошибка маршрута: $error';
  }

  @override
  String get lightAdded => 'Светофор добавлен';

  @override
  String addError(String error) {
    return 'Ошибка добавления: $error';
  }

  @override
  String get explorerTooltip => 'Обзор';

  @override
  String get refresh => 'Обновить';

  @override
  String get profileCar => 'Авто';

  @override
  String get profileFoot => 'Пешком';

  @override
  String get profileBike => 'Велосипед';

  @override
  String tileLoadError(String error) {
    return 'Ошибка загрузки тайлов: $error';
  }

  @override
  String speedAdvice(num speed) {
    return 'Едьте ~$speed км/ч';
  }

  @override
  String get notEnoughData =>
      'Недостаточно данных. Проедьте с авто‑логом камеры.';

  @override
  String get noLightsOnRoute => 'На маршруте нет светофоров';

  @override
  String get legendMinor => 'Второстепенная';

  @override
  String get legendMain => 'Главная';

  @override
  String get legendPed => 'Пешеходы';

  @override
  String get clearRoute => 'Сбросить маршрут';

  @override
  String get myLocation => 'Моё местоположение';

  @override
  String get addLight => 'Добавить светофор';

  @override
  String get cameraTitle => 'Камера — авто‑лог';

  @override
  String roiInfo(String color) {
    return 'ROI: тап по кадру • Цвет: $color';
  }

  @override
  String get noCameraPermission =>
      'Нет разрешения на камеру. Включите в настройках.';

  @override
  String get cameraNotFound => 'Камера не найдена на устройстве.';

  @override
  String cameraError(String error) {
    return 'Ошибка камеры: $error';
  }

  @override
  String get adviceTitle => 'Совет по скорости';

  @override
  String cycleInfo(num cycle, num red, num yellow, num green) {
    return 'Цикл $cycleс (К $red / Ж $yellow / З $green)';
  }

  @override
  String holdSpeed(num low, num high) {
    return 'Держите ~$low–$high км/ч';
  }

  @override
  String get unitsKmh => 'Единицы';

  @override
  String get roadSpeedLimit => 'Ограничение скорости (км/ч)';

  @override
  String get cameraOffset => 'Смещение часов камеры (с)';

  @override
  String get jerkStep => 'Шаг изменения совета';
}
