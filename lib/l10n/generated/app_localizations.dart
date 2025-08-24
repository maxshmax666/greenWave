import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// App title on the home screen
  ///
  /// In en, this message translates to:
  /// **'GreenWave'**
  String get appTitle;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navLights.
  ///
  /// In en, this message translates to:
  /// **'Lights'**
  String get navLights;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @lights.
  ///
  /// In en, this message translates to:
  /// **'Lights'**
  String get lights;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'I have an account'**
  String get haveAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @slogan.
  ///
  /// In en, this message translates to:
  /// **'Ride the wave'**
  String get slogan;

  /// No description provided for @lightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lights'**
  String get lightsTitle;

  /// Error when loading lights
  ///
  /// In en, this message translates to:
  /// **'Failed to load lights: {error}'**
  String failedLoadLights(String error);

  /// No description provided for @noCoords.
  ///
  /// In en, this message translates to:
  /// **'no coords'**
  String get noCoords;

  /// Title with light id
  ///
  /// In en, this message translates to:
  /// **'Light {id}'**
  String lightWithId(int id);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @supabaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Supabase URL'**
  String get supabaseUrl;

  /// No description provided for @supabaseKey.
  ///
  /// In en, this message translates to:
  /// **'Supabase Key'**
  String get supabaseKey;

  /// Routing error message
  ///
  /// In en, this message translates to:
  /// **'Route error: {error}'**
  String routeError(String error);

  /// No description provided for @lightAdded.
  ///
  /// In en, this message translates to:
  /// **'Light added'**
  String get lightAdded;

  /// Error on adding item
  ///
  /// In en, this message translates to:
  /// **'Add error: {error}'**
  String addError(String error);

  /// No description provided for @explorerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get explorerTooltip;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @profileCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get profileCar;

  /// No description provided for @profileFoot.
  ///
  /// In en, this message translates to:
  /// **'Foot'**
  String get profileFoot;

  /// No description provided for @profileBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get profileBike;

  /// Map tile loading error
  ///
  /// In en, this message translates to:
  /// **'Tile load error: {error}'**
  String tileLoadError(String error);

  /// Single speed advice
  ///
  /// In en, this message translates to:
  /// **'Go ~{speed} km/h'**
  String speedAdvice(num speed);

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data. Ride with camera autolog.'**
  String get notEnoughData;

  /// No description provided for @noLightsOnRoute.
  ///
  /// In en, this message translates to:
  /// **'No lights on route'**
  String get noLightsOnRoute;

  /// No description provided for @legendMinor.
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get legendMinor;

  /// No description provided for @legendMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get legendMain;

  /// No description provided for @legendPed.
  ///
  /// In en, this message translates to:
  /// **'Pedestrians'**
  String get legendPed;

  /// No description provided for @clearRoute.
  ///
  /// In en, this message translates to:
  /// **'Clear route'**
  String get clearRoute;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @addLight.
  ///
  /// In en, this message translates to:
  /// **'Add light'**
  String get addLight;

  /// No description provided for @cameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera — auto log'**
  String get cameraTitle;

  /// ROI hint text
  ///
  /// In en, this message translates to:
  /// **'ROI: tap frame • Color: {color}'**
  String roiInfo(String color);

  /// No description provided for @noCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'No camera permission. Enable in settings.'**
  String get noCameraPermission;

  /// No description provided for @cameraNotFound.
  ///
  /// In en, this message translates to:
  /// **'Camera not found on device.'**
  String get cameraNotFound;

  /// Camera error message
  ///
  /// In en, this message translates to:
  /// **'Camera error: {error}'**
  String cameraError(String error);

  /// No description provided for @adviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Speed advice'**
  String get adviceTitle;

  /// Cycle description with components
  ///
  /// In en, this message translates to:
  /// **'Cycle {cycle}s (R {red} / Y {yellow} / G {green})'**
  String cycleInfo(num cycle, num red, num yellow, num green);

  /// Speed range to hold
  ///
  /// In en, this message translates to:
  /// **'Keep ~{low}–{high} km/h'**
  String holdSpeed(num low, num high);

  /// No description provided for @unitsKmh.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsKmh;

  /// No description provided for @roadSpeedLimit.
  ///
  /// In en, this message translates to:
  /// **'Road speed limit (km/h)'**
  String get roadSpeedLimit;

  /// No description provided for @cameraOffset.
  ///
  /// In en, this message translates to:
  /// **'Camera clock offset (s)'**
  String get cameraOffset;

  /// No description provided for @jerkStep.
  ///
  /// In en, this message translates to:
  /// **'Advisor jerk step'**
  String get jerkStep;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
