// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'AgroVision';

  @override
  String get smart_farming_assistant => 'Smart Farming Assistant';

  @override
  String get enter_phone_number => 'Enter Phone Number';

  @override
  String get phone_hint => '10-digit mobile number';

  @override
  String get send_otp => 'Send OTP';

  @override
  String get otp_verification => 'OTP Verification';

  @override
  String enter_otp_sent_to(String phoneNumber) {
    return 'Enter the code sent to $phoneNumber';
  }

  @override
  String get verify_otp => 'Verify OTP';

  @override
  String get resend_otp => 'Resend OTP';

  @override
  String get otp_resent => 'OTP Resent!';

  @override
  String get please_enter_valid_phone => 'Please enter a valid 10-digit number';

  @override
  String get please_enter_valid_otp => 'Please enter a valid 6-digit OTP';

  @override
  String get verification_failed => 'Verification Failed';

  @override
  String get invalid_phone_number => 'The provided phone number is not valid.';

  @override
  String get too_many_requests => 'Too many requests. Try again later.';

  @override
  String get otp_incorrect => 'The OTP entered is incorrect.';

  @override
  String get otp_expired => 'The OTP has expired. Please resend.';

  @override
  String get unexpected_error => 'An unexpected error occurred';

  @override
  String get terms_and_conditions =>
      'By continuing, you agree to our Terms & Conditions';

  @override
  String get select_language => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'Tamil';

  @override
  String get greeting => 'Welcome, Farmer';

  @override
  String get today_weather => 'Today\'s Weather';

  @override
  String get humidity => 'Humidity';

  @override
  String get wind => 'Wind';

  @override
  String get rain => 'Rain';

  @override
  String get view_details => 'View Details';

  @override
  String get farm_tools => 'Farm Tools';

  @override
  String get crop_disease => 'Crop Disease Detection';

  @override
  String get soil_analysis => 'Soil Analysis';

  @override
  String get satellite_monitoring => 'Satellite Monitoring';

  @override
  String get gov_schemes => 'Government Schemes';
}
