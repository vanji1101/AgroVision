import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import 'package:intl/intl.dart';

class WeatherService {
  // OpenWeatherMap API Key (Get from: https://openweathermap.org/api)
  // இங்க உங்க API Key-ஐ பேஸ்ட் பண்ணுங்க 👇
  static const String _owmKey = "e15cc5957678b76719a77b59a0ecb2d0"; // Paste your key here

  static const String _omBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _owmBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData> fetchWeather(double lat, double lon, {String? manualName}) async {
    try {
      // 1. Fetch from Open-Meteo (Primary for Agri-data)
      String url = '$_omBaseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m&hourly=temperature_2m,precipitation_probability,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto';
      var omResponse = await http.get(Uri.parse(url));

      if (omResponse.statusCode == 400 && omResponse.body.contains("Timezone")) {
        url = url.replaceAll('timezone=auto', 'timezone=Asia%2FKolkata');
        omResponse = await http.get(Uri.parse(url));
      }

      if (omResponse.statusCode != 200) {
        throw Exception('Open-Meteo failed: ${omResponse.statusCode}');
      }
      final omData = json.decode(omResponse.body);

      // Get location name
      String locationName = manualName ?? "Current Location";

      // Only geocode if manual name is not provided
      if (manualName == null || manualName.isEmpty) {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            String city = place.locality ?? "";
            String district = place.subAdministrativeArea ?? "";
            locationName = city.isNotEmpty ? city : (district.isNotEmpty ? district : "Current Location");
          }
        } catch (e) {
          debugPrint("Geocoding failed: $e");
        }
      }
      
      // 2. Fetch from OpenWeatherMap (For Alerts and fallback name)
      String alert = "";
      if (_owmKey.isNotEmpty) {
        try {
          final owmResponse = await http.get(Uri.parse('$_owmBaseUrl?lat=$lat&lon=$lon&appid=$_owmKey&units=metric'));
          if (owmResponse.statusCode == 200) {
            final owmData = json.decode(owmResponse.body);
            
            // Fallback name if geocoding failed
            if (locationName == "Current Location" && owmData['name'] != null) {
              locationName = owmData['name'];
            }

            if (owmData['weather'][0]['main'] == 'Thunderstorm' || owmData['wind']['speed'] > 15) {
              alert = "⚠️ OWM Alert: Severe ${owmData['weather'][0]['description']} detected!";
            }
          }
        } catch (e) {
          print("OWM Fetch failed: $e");
        }
      }

      // If no OWM alert, fallback to our logic-based alert from Open-Meteo
      if (alert.isEmpty) {
        alert = _calculateAlert(
          omData['current']['wind_speed_10m'].toDouble(),
          omData['current']['temperature_2m'].toDouble(),
          omData['current']['precipitation'].toDouble(),
          locationName,
        );
      }

      // Parse hourly
      List<HourlyForecast> hourly = [];
      for (int i = 0; i < 24; i++) {
        DateTime time = DateTime.parse(omData['hourly']['time'][i]);
        hourly.add(HourlyForecast(
          time: DateFormat('h a').format(time),
          temp: omData['hourly']['temperature_2m'][i].toDouble(),
          icon: _getWeatherIcon(omData['hourly']['weather_code'][i]),
          rainProb: omData['hourly']['precipitation_probability'][i].toDouble(),
        ));
      }

      // Parse daily
      List<DailyForecast> daily = [];
      for (int i = 0; i < 7; i++) {
        DateTime date = DateTime.parse(omData['daily']['time'][i]);
        daily.add(DailyForecast(
          day: DateFormat('EEE').format(date),
          tamilDay: _getTamilDay(date.weekday),
          icon: _getWeatherIcon(omData['daily']['weather_code'][i]),
          rainProb: omData['daily']['precipitation_probability_max'][i].toDouble(),
          highTemp: omData['daily']['temperature_2m_max'][i].toDouble(),
          lowTemp: omData['daily']['temperature_2m_min'][i].toDouble(),
        ));
      }

      return WeatherData(
        temperature: omData['current']['temperature_2m'].toDouble(),
        humidity: omData['current']['relative_humidity_2m'].toDouble(),
        windSpeed: omData['current']['wind_speed_10m'].toDouble(),
        rainProbability: omData['daily']['precipitation_probability_max'][0].toDouble(),
        condition: _getWeatherCondition(omData['current']['weather_code']),
        icon: _getWeatherIcon(omData['current']['weather_code']),
        locationName: locationName,
        hourly: hourly,
        daily: daily,
        alert: alert,
      );
    } catch (e) {
      throw Exception('Failed to load weather: $e');
    }
  }

  String _calculateAlert(double windSpeed, double temp, double rain, String location) {
    location = location.toLowerCase();
    bool isCoastal = location.contains('chennai') || location.contains('cuddalore') || 
                     location.contains('kanyakumari') || location.contains('nagapattinam') || 
                     location.contains('thoothukudi') || location.contains('coastal');

    if (isCoastal && windSpeed > 40) return "🌊 சுனாமி / கடல் சீற்ற எச்சரிக்கை! (Tsunami/Coastal Alert) - Move to higher ground.";
    if (windSpeed > 45) return "🌪 கடும் புயல் எச்சரிக்கை! (Cyclone / Storm Alert) - Secure your farm and stay indoors.";
    if (temp > 39) return "☀️ கடும் வெப்ப அலை! (Heatwave) - Avoid field work at noon, stay hydrated.";
    if (rain > 10 || windSpeed > 30) return "🌧 கனமழை எச்சரிக்கை! (Heavy Rain) - Protect crops from waterlogging.";
    
    return "";
  }

  String _getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 99) return '⛈️';
    return '☁️';
  }

  String _getWeatherCondition(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Cloudy';
  }

  String _getTamilDay(int day) {
    const tamilDays = {1: 'திங்கள்', 2: 'செவ்வாய்', 3: 'புதன்', 4: 'வியாழன்', 5: 'வெள்ளி', 6: 'சனி', 7: 'ஞாயிறு'};
    return tamilDays[day] ?? '';
  }
}
