// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GreenWave';

  @override
  String get navMap => 'Map';

  @override
  String get navLights => 'Lights';

  @override
  String get navCycles => 'Cycles';

  @override
  String get navRecord => 'Record';

  @override
  String get navSettings => 'Settings';

  @override
  String get map => 'Map';

  @override
  String get lights => 'Lights';

  @override
  String get settings => 'Settings';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccount => 'Create account';

  @override
  String get haveAccount => 'I have an account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get slogan => 'Ride the wave';

  @override
  String get lightsTitle => 'Lights';

  @override
  String failedLoadLights(String error) {
    return 'Failed to load lights: $error';
  }

  @override
  String get noCoords => 'no coords';

  @override
  String lightWithId(int id) {
    return 'Light $id';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get language => 'Language';

  @override
  String get supabaseUrl => 'Supabase URL';

  @override
  String get supabaseKey => 'Supabase Key';

  @override
  String routeError(String error) {
    return 'Route error: $error';
  }

  @override
  String get lightAdded => 'Light added';

  @override
  String addError(String error) {
    return 'Add error: $error';
  }

  @override
  String get explorerTooltip => 'Explorer';

  @override
  String get refresh => 'Refresh';

  @override
  String get profileCar => 'Car';

  @override
  String get profileFoot => 'Foot';

  @override
  String get profileBike => 'Bike';

  @override
  String tileLoadError(String error) {
    return 'Tile load error: $error';
  }

  @override
  String speedAdvice(num speed) {
    return 'Go ~$speed km/h';
  }

  @override
  String get notEnoughData => 'Not enough data. Ride with camera autolog.';

  @override
  String get noLightsOnRoute => 'No lights on route';

  @override
  String get legendMinor => 'Minor';

  @override
  String get legendMain => 'Main';

  @override
  String get legendPed => 'Pedestrians';

  @override
  String get clearRoute => 'Clear route';

  @override
  String get myLocation => 'My location';

  @override
  String get addLight => 'Add light';

  @override
  String get cameraTitle => 'Camera — auto log';

  @override
  String roiInfo(String color) {
    return 'ROI: tap frame • Color: $color';
  }

  @override
  String get noCameraPermission => 'No camera permission. Enable in settings.';

  @override
  String get cameraNotFound => 'Camera not found on device.';

  @override
  String cameraError(String error) {
    return 'Camera error: $error';
  }

  @override
  String get adviceTitle => 'Speed advice';

  @override
  String cycleInfo(num cycle, num red, num yellow, num green) {
    return 'Cycle ${cycle}s (R $red / Y $yellow / G $green)';
  }

  @override
  String holdSpeed(num low, num high) {
    return 'Keep ~$low–$high km/h';
  }

  @override
  String get unitsKmh => 'Units';

  @override
  String get roadSpeedLimit => 'Road speed limit (km/h)';

  @override
  String get cameraOffset => 'Camera clock offset (s)';

  @override
  String get jerkStep => 'Advisor jerk step';
}
