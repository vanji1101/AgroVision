import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ta'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'AgroVision'**
  String get app_name;

  /// No description provided for @smart_farming_assistant.
  ///
  /// In en, this message translates to:
  /// **'Smart Farming Assistant'**
  String get smart_farming_assistant;

  /// No description provided for @enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get enter_phone_number;

  /// No description provided for @phone_hint.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get phone_hint;

  /// No description provided for @send_otp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get send_otp;

  /// No description provided for @otp_verification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otp_verification;

  /// No description provided for @enter_otp_sent_to.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {phoneNumber}'**
  String enter_otp_sent_to(String phoneNumber);

  /// No description provided for @verify_otp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verify_otp;

  /// No description provided for @resend_otp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resend_otp;

  /// No description provided for @otp_resent.
  ///
  /// In en, this message translates to:
  /// **'OTP Resent!'**
  String get otp_resent;

  /// No description provided for @please_enter_valid_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit number'**
  String get please_enter_valid_phone;

  /// No description provided for @please_enter_valid_otp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit OTP'**
  String get please_enter_valid_otp;

  /// No description provided for @verification_failed.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get verification_failed;

  /// No description provided for @invalid_phone_number.
  ///
  /// In en, this message translates to:
  /// **'The provided phone number is not valid.'**
  String get invalid_phone_number;

  /// No description provided for @too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again later.'**
  String get too_many_requests;

  /// No description provided for @otp_incorrect.
  ///
  /// In en, this message translates to:
  /// **'The OTP entered is incorrect.'**
  String get otp_incorrect;

  /// No description provided for @otp_expired.
  ///
  /// In en, this message translates to:
  /// **'The OTP has expired. Please resend.'**
  String get otp_expired;

  /// No description provided for @unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpected_error;

  /// No description provided for @terms_and_conditions.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms & Conditions'**
  String get terms_and_conditions;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Farmer'**
  String get greeting;

  /// No description provided for @today_weather.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Weather'**
  String get today_weather;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rain;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @farm_tools.
  ///
  /// In en, this message translates to:
  /// **'Farm Tools'**
  String get farm_tools;

  /// No description provided for @crop_disease.
  ///
  /// In en, this message translates to:
  /// **'Crop Disease Detection'**
  String get crop_disease;

  /// No description provided for @soil_analysis.
  ///
  /// In en, this message translates to:
  /// **'Soil Analysis'**
  String get soil_analysis;

  /// No description provided for @satellite_monitoring.
  ///
  /// In en, this message translates to:
  /// **'Satellite Monitoring'**
  String get satellite_monitoring;

  /// No description provided for @gov_schemes.
  ///
  /// In en, this message translates to:
  /// **'Government Schemes'**
  String get gov_schemes;
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
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
