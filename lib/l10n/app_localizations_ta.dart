// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get app_name => 'AgroVision';

  @override
  String get smart_farming_assistant => 'ஸ்மார்ட் விவசாய உதவியாளர்';

  @override
  String get enter_phone_number => 'அலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get phone_hint => '10 இலக்க மொபைல் எண்';

  @override
  String get send_otp => 'OTP அனுப்பவும்';

  @override
  String get otp_verification => 'OTP சரிபார்ப்பு';

  @override
  String enter_otp_sent_to(String phoneNumber) {
    return '$phoneNumber என்ற எண்ணிற்கு அனுப்பப்பட்ட குறியீட்டை உள்ளிடவும்';
  }

  @override
  String get verify_otp => 'சரிபார்க்கவும்';

  @override
  String get resend_otp => 'மீண்டும் அனுப்பவும்';

  @override
  String get otp_resent => 'OTP மீண்டும் அனுப்பப்பட்டது!';

  @override
  String get please_enter_valid_phone => 'சரியான 10 இலக்க எண்ணை உள்ளிடவும்';

  @override
  String get please_enter_valid_otp => 'சரியான 6 இலக்க OTP ஐ உள்ளிடவும்';

  @override
  String get verification_failed => 'சரிபார்ப்பு தோல்வியடைந்தது';

  @override
  String get invalid_phone_number =>
      'வழங்கப்பட்ட தொலைபேசி எண் செல்லுபடியாகாது.';

  @override
  String get too_many_requests =>
      'அதிகப்படியான கோரிக்கைகள். சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get otp_incorrect => 'உள்ளிடப்பட்ட OTP தவறானது.';

  @override
  String get otp_expired => 'OTP காலாவதியாகிவிட்டது. மீண்டும் அனுப்பவும்.';

  @override
  String get unexpected_error => 'எதிர்பாராத பிழை ஏற்பட்டது';

  @override
  String get terms_and_conditions =>
      'தொடர்வதன் மூலம், எங்கள் விதிமுறைகள் மற்றும் நிபந்தனைகளை ஒப்புக்கொள்கிறீர்கள்';

  @override
  String get select_language => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get english => 'ஆங்கிலம்';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get greeting => 'வணக்கம், விவசாயி';

  @override
  String get today_weather => 'இன்றைய வானிலை';

  @override
  String get humidity => 'ஈரப்பதம்';

  @override
  String get wind => 'காற்று';

  @override
  String get rain => 'மழை';

  @override
  String get view_details => 'விவரங்களைக் காண்க';

  @override
  String get farm_tools => 'பண்ணை கருவிகள்';

  @override
  String get crop_disease => 'பயிர் நோய் கண்டறிதல்';

  @override
  String get soil_analysis => 'மண் ஆய்வு';

  @override
  String get satellite_monitoring => 'செயற்கைக்கோள் கண்காணிப்பு';

  @override
  String get gov_schemes => 'அரசு திட்டங்கள்';
}
